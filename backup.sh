#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
# TV BOX FIRMWARE BACKUP TOOL
# Backup only - NO RESTORE / NO FLASH
# Output: /sdcard/TVBoxFirmware/
# ============================================================

set -u

BASE="/sdcard/TVBoxFirmware"
DATE="$(date '+%Y%m%d_%H%M%S')"
OUT="$BASE/TVBOX_$DATE"

BOOT="$OUT/BOOT"
FIRMWARE="$OUT/FIRMWARE"
BOOTLOADER="$OUT/BOOTLOADER_REVIEW"
SECURITY="$OUT/SECURITY_REVIEW"

mkdir -p "$BOOT" "$FIRMWARE" "$BOOTLOADER" "$SECURITY"

REPORT="$OUT/BACKUP_REPORT.txt"
HW="$OUT/HARDWARE.txt"
PARTS="$OUT/partition-list.txt"
SHA="$OUT/SHA256SUMS"
MANIFEST="$OUT/FIRMWARE_MANIFEST.txt"
FLASH="$OUT/FLASH_CANDIDATES.txt"

echo "==================================================" | tee "$REPORT"
echo "       TV BOX FIRMWARE BACKUP" | tee -a "$REPORT"
echo "       $DATE" | tee -a "$REPORT"
echo "==================================================" | tee -a "$REPORT"
echo "" | tee -a "$REPORT"

# ------------------------------------------------------------
# CHECK ADB
# ------------------------------------------------------------

if ! command -v adb >/dev/null 2>&1; then
    echo "ERROR: adb পাওয়া যায়নি।"
    echo "Install: pkg install android-tools"
    exit 1
fi

echo "[1] Checking ADB..."

adb start-server >/dev/null 2>&1

STATE="$(adb get-state 2>/dev/null || true)"

if [ "$STATE" != "device" ]; then
    echo ""
    echo "ERROR: TV Box ADB device হিসেবে connected নেই।"
    echo ""
    adb devices
    echo ""
    echo "TV Box-এ USB/WiFi debugging এবং ADB চালু করুন।"
    exit 1
fi

echo "ADB: OK" | tee -a "$REPORT"

# ------------------------------------------------------------
# ROOT CHECK
# ------------------------------------------------------------

echo ""
echo "[2] Checking root access..."

ROOT_TEST="$(adb shell su -c 'id' 2>/dev/null || true)"

if ! echo "$ROOT_TEST" | grep -q "uid=0"; then
    echo ""
    echo "ERROR: TV Box-এ root access পাওয়া যায়নি।"
    echo ""
    echo "Protected firmware partitions backup করার জন্য root প্রয়োজন।"
    echo "Backup বন্ধ করা হলো।"
    exit 1
fi

echo "ROOT: OK" | tee -a "$REPORT"

# ------------------------------------------------------------
# HARDWARE INFORMATION
# ------------------------------------------------------------

echo ""
echo "[3] Reading hardware information..."

{
    echo "================ HARDWARE INFO ================"
    echo ""
    echo "Date:"
    echo "$DATE"
    echo ""

    echo "Manufacturer:"
    adb shell getprop ro.product.manufacturer 2>/dev/null

    echo "Brand:"
    adb shell getprop ro.product.brand 2>/dev/null

    echo "Model:"
    adb shell getprop ro.product.model 2>/dev/null

    echo "Device:"
    adb shell getprop ro.product.device 2>/dev/null

    echo "Board:"
    adb shell getprop ro.product.board 2>/dev/null

    echo "Hardware:"
    adb shell getprop ro.hardware 2>/dev/null

    echo "Platform:"
    adb shell getprop ro.board.platform 2>/dev/null

    echo "SOC:"
    adb shell getprop ro.soc.manufacturer 2>/dev/null
    adb shell getprop ro.soc.model 2>/dev/null

    echo "Android:"
    adb shell getprop ro.build.version.release 2>/dev/null

    echo "SDK:"
    adb shell getprop ro.build.version.sdk 2>/dev/null

    echo "Build:"
    adb shell getprop ro.build.display.id 2>/dev/null

    echo "Fingerprint:"
    adb shell getprop ro.build.fingerprint 2>/dev/null

    echo ""
    echo "ABI:"
    adb shell getprop ro.product.cpu.abi 2>/dev/null
    adb shell getprop ro.product.cpu.abilist 2>/dev/null

    echo ""
    echo "Kernel:"
    adb shell uname -a 2>/dev/null

    echo ""
    echo "Memory:"
    adb shell cat /proc/meminfo 2>/dev/null | head -n 15

    echo ""
    echo "Block Devices:"
    adb shell ls -l /dev/block/ 2>/dev/null

    echo ""
    echo "================================================"
} > "$HW"

cat "$HW" >> "$REPORT"

# ------------------------------------------------------------
# FIND PARTITION BY-NAME DIRECTORY
# ------------------------------------------------------------

echo ""
echo "[4] Finding partition table..."

BYNAME="$(adb shell su -c '
for p in \
/dev/block/by-name \
/dev/block/platform/*/by-name \
/dev/block/platform/*/*/by-name \
/dev/block/platform/*/*/*/by-name; do
    if [ -d "$p" ]; then
        echo "$p"
        exit 0
    fi
done
' 2>/dev/null | tr -d '\r' | head -n 1)"

if [ -z "$BYNAME" ]; then
    echo ""
    echo "ERROR: /dev/block/by-name পাওয়া যায়নি।"
    echo "Partition layout manually inspect করতে হবে।"
    exit 1
fi

echo "Partition path: $BYNAME" | tee -a "$REPORT"

# ------------------------------------------------------------
# PARTITION LIST
# ------------------------------------------------------------

adb shell su -c "ls -l '$BYNAME'" 2>/dev/null \
    | tr -d '\r' > "$PARTS"

echo "" >> "$REPORT"
echo "================ PARTITIONS ================" >> "$REPORT"
cat "$PARTS" >> "$REPORT"
echo "============================================" >> "$REPORT"

# ------------------------------------------------------------
# HELPER FUNCTIONS
# ------------------------------------------------------------

has_partition() {
    local P="$1"

    adb shell su -c "[ -e '$BYNAME/$P' ] && echo YES || echo NO" \
        2>/dev/null | tr -d '\r'
}

get_size() {
    local P="$1"

    adb shell su -c "
        if [ -e '$BYNAME/$P' ]; then
            blockdev --getsize64 '$BYNAME/$P' 2>/dev/null
        fi
    " 2>/dev/null | tr -d '\r'
}

backup_partition() {
    local P="$1"
    local DEST="$2"

    local SRC="$BYNAME/$P"
    local SIZE

    SIZE="$(get_size "$P")"

    if [ -z "$SIZE" ] || [ "$SIZE" = "0" ]; then
        echo "SKIP: $P - size পাওয়া যায়নি"
        return 1
    fi

    echo ""
    echo "--------------------------------------------------"
    echo "Backing up: $P"
    echo "Size: $SIZE bytes"
    echo "Destination: $DEST/$P.img"
    echo "--------------------------------------------------"

    # Phone free-space check
    local FREE
    FREE="$(df -k "$OUT" 2>/dev/null | tail -n 1 | awk '{print $4}')"

    if [ -n "$FREE" ]; then
        local REQUIRED_KB
        REQUIRED_KB=$(( (SIZE / 1024) + 10240 ))

        if [ "$FREE" -lt "$REQUIRED_KB" ]; then
            echo "ERROR: Phone storage কম। $P backup করা হলো না।"
            echo "Required approx: $REQUIRED_KB KB"
            echo "Free: $FREE KB"
            return 1
        fi
    fi

    # Direct binary dump from TV Box -> Phone
    if adb exec-out su -c "dd if='$SRC' bs=4M 2>/dev/null" > "$DEST/$P.img"; then

        local ACTUAL
        ACTUAL="$(stat -c '%s' "$DEST/$P.img" 2>/dev/null || echo 0)"

        if [ "$ACTUAL" -eq "$SIZE" ]; then
            echo "OK: $P.img"
            return 0
        else
            echo "WARNING: $P size mismatch!"
            echo "Expected: $SIZE"
            echo "Got:      $ACTUAL"
            rm -f "$DEST/$P.img"
            return 1
        fi

    else
        echo "ERROR: $P backup failed"
        rm -f "$DEST/$P.img"
        return 1
    fi
}

add_candidate() {
    local P="$1"

    if [ "$(has_partition "$P")" = "YES" ]; then
        echo "$P"
    fi
}

# ------------------------------------------------------------
# CLASSIFICATION
# ------------------------------------------------------------

echo ""
echo "[5] Classifying partitions..."

BOOT_LIST=()
FIRMWARE_LIST=()
BOOTLOADER_LIST=()
SECURITY_LIST=()
EXCLUDED_LIST=()

# ------------------------------------------------------------
# NORMAL BOOT PARTITIONS
# ------------------------------------------------------------

BOOT_NAMES="
boot
boot_a
boot_b
vendor_boot
vendor_boot_a
vendor_boot_b
init_boot
init_boot_a
init_boot_b
recovery
recovery_a
recovery_b
dtbo
dtbo_a
dtbo_b
vbmeta
vbmeta_a
vbmeta_b
vbmeta_system
vbmeta_system_a
vbmeta_system_b
vbmeta_vendor
vbmeta_vendor_a
vbmeta_vendor_b
"

for P in $BOOT_NAMES; do
    if [ "$(has_partition "$P")" = "YES" ]; then
        BOOT_LIST+=("$P")
    fi
done

# ------------------------------------------------------------
# ANDROID FIRMWARE
# ------------------------------------------------------------

FIRMWARE_NAMES="
super
system
system_a
system_b
system_ext
system_ext_a
system_ext_b
vendor
vendor_a
vendor_b
product
product_a
product_b
odm
odm_a
odm_b
"

for P in $FIRMWARE_NAMES; do
    if [ "$(has_partition "$P")" = "YES" ]; then
        FIRMWARE_LIST+=("$P")
    fi
done

# ------------------------------------------------------------
# BOOTLOADER REVIEW
# These are backed up separately.
# NOT automatically declared safe to flash.
# ------------------------------------------------------------

BOOTLOADER_NAMES="
preloader
preloader_a
preloader_b
lk
lk_a
lk_b
abl
abl_a
abl_b
xbl
xbl_a
xbl_b
xbl_config
xbl_config_a
xbl_config_b
u-boot
u-boot_a
u-boot_b
uboot
uboot_a
uboot_b
bootloader
bootloader_a
bootloader_b
spl
spl_a
spl_b
loader
loader_a
loader_b
fastboot
fastboot_a
fastboot_b
trust
trust_a
trust_b
"

for P in $BOOTLOADER_NAMES; do
    if [ "$(has_partition "$P")" = "YES" ]; then
        BOOTLOADER_LIST+=("$P")
    fi
done

# ------------------------------------------------------------
# SECURITY / DEVICE-SPECIFIC
# NEVER USED AS NORMAL FLASH CANDIDATE
# ------------------------------------------------------------

SECURITY_NAMES="
tee
tee_a
tee_b
tz
tz_a
tz_b
trustzone
trustzone_a
trustzone_b
keymaster
keymaster_a
keymaster_b
keystore
keystore_a
keystore_b
"

for P in $SECURITY_NAMES; do
    if [ "$(has_partition "$P")" = "YES" ]; then
        SECURITY_LIST+=("$P")
    fi
done

# ------------------------------------------------------------
# DEVICE SPECIFIC / USER DATA
# ------------------------------------------------------------

EXCLUDE_NAMES="
userdata
data
cache
metadata
misc
persist
persistent
nvram
nvdata
protect
protect1
protect2
efs
modemst
modemst1
modemst2
fsg
fsc
factory
factory_a
factory_b
frp
proinfo
proinfo_a
proinfo_b
calibration
calib
wifi
bluetooth
bt
vendor_persist
deviceinfo
devinfo
cid
serial
mac
"

for P in $EXCLUDE_NAMES; do
    if [ "$(has_partition "$P")" = "YES" ]; then
        EXCLUDED_LIST+=("$P")
    fi
done

# ------------------------------------------------------------
# WRITE FLASH CANDIDATES
# ------------------------------------------------------------

{
    echo "=================================================="
    echo "NORMAL FLASH CANDIDATES"
    echo "=================================================="
    echo ""
    echo "These are the normal firmware candidates."
    echo "They still require same-board/model compatibility."
    echo ""

    echo "[BOOT]"
    for P in "${BOOT_LIST[@]}"; do
        echo "$P.img"
    done

    echo ""
    echo "[FIRMWARE]"
    for P in "${FIRMWARE_LIST[@]}"; do
        echo "$P.img"
    done

    echo ""
    echo "=================================================="
    echo "BOOTLOADER REVIEW"
    echo "=================================================="
    echo ""
    echo "These are backed up separately."
    echo "DO NOT flash blindly."
    echo "Verify exact board/revision/vendor first."
    echo ""

    for P in "${BOOTLOADER_LIST[@]}"; do
        echo "$P.img"
    done

    echo ""
    echo "=================================================="
    echo "EXCLUDED"
    echo "=================================================="
    echo ""
    echo "Device-specific/user/security partitions are"
    echo "not included as normal flash candidates."
    echo ""

    for P in "${EXCLUDED_LIST[@]}"; do
        echo "$P"
    done
} > "$FLASH"

# ------------------------------------------------------------
# MANIFEST
# ------------------------------------------------------------

{
    echo "TV BOX FIRMWARE MANIFEST"
    echo "========================"
    echo ""
    echo "Backup: TVBOX_$DATE"
    echo ""
    echo "BOOT:"
    for P in "${BOOT_LIST[@]}"; do
        echo "  $P.img"
    done

    echo ""
    echo "FIRMWARE:"
    for P in "${FIRMWARE_LIST[@]}"; do
        echo "  $P.img"
    done

    echo ""
    echo "BOOTLOADER_REVIEW:"
    for P in "${BOOTLOADER_LIST[@]}"; do
        echo "  $P.img"
    done

    echo ""
    echo "SECURITY_REVIEW:"
    for P in "${SECURITY_LIST[@]}"; do
        echo "  $P"
    done

    echo ""
    echo "EXCLUDED_DEVICE_SPECIFIC:"
    for P in "${EXCLUDED_LIST[@]}"; do
        echo "  $P"
    done
} > "$MANIFEST"

# ------------------------------------------------------------
# BACKUP BOOT
# ------------------------------------------------------------

echo ""
echo "=================================================="
echo "BACKUP: BOOT"
echo "=================================================="

BOOT_OK=0
BOOT_FAIL=0

for P in "${BOOT_LIST[@]}"; do
    if backup_partition "$P" "$BOOT"; then
        BOOT_OK=$((BOOT_OK + 1))
    else
        BOOT_FAIL=$((BOOT_FAIL + 1))
    fi
done

# ------------------------------------------------------------
# BACKUP FIRMWARE
# ------------------------------------------------------------

echo ""
echo "=================================================="
echo "BACKUP: FIRMWARE"
echo "=================================================="

FIRMWARE_OK=0
FIRMWARE_FAIL=0

for P in "${FIRMWARE_LIST[@]}"; do
    if backup_partition "$P" "$FIRMWARE"; then
        FIRMWARE_OK=$((FIRMWARE_OK + 1))
    else
        FIRMWARE_FAIL=$((FIRMWARE_FAIL + 1))
    fi
done

# ------------------------------------------------------------
# BACKUP BOOTLOADER REVIEW
# ------------------------------------------------------------

echo ""
echo "=================================================="
echo "BACKUP: BOOTLOADER_REVIEW"
echo "=================================================="

BOOTLOADER_OK=0
BOOTLOADER_FAIL=0

for P in "${BOOTLOADER_LIST[@]}"; do
    if backup_partition "$P" "$BOOTLOADER"; then
        BOOTLOADER_OK=$((BOOTLOADER_OK + 1))
    else
        BOOTLOADER_FAIL=$((BOOTLOADER_FAIL + 1))
    fi
done

# ------------------------------------------------------------
# SECURITY LIST ONLY
# ------------------------------------------------------------

{
    echo "SECURITY / DEVICE-BOUND PARTITIONS"
    echo "=================================="
    echo ""
    echo "These partitions were intentionally NOT dumped."
    echo "They may contain keys, device identity or security data."
    echo ""
    for P in "${SECURITY_LIST[@]}"; do
        echo "$P"
    done
} > "$SECURITY/README.txt"

# ------------------------------------------------------------
# HASH
# ------------------------------------------------------------

echo ""
echo "[6] Creating SHA256 checksums..."

find "$BOOT" "$FIRMWARE" "$BOOTLOADER" \
    -type f -name "*.img" -print0 2>/dev/null \
    | sort -z \
    | while IFS= read -r -d '' FILE; do
        sha256sum "$FILE"
    done > "$SHA"

# ------------------------------------------------------------
# FINAL REPORT
# ------------------------------------------------------------

{
    echo ""
    echo "=================================================="
    echo "BACKUP SUMMARY"
    echo "=================================================="
    echo ""
    echo "Output:"
    echo "$OUT"
    echo ""
    echo "BOOT successful : $BOOT_OK"
    echo "BOOT failed     : $BOOT_FAIL"
    echo ""
    echo "FIRMWARE successful : $FIRMWARE_OK"
    echo "FIRMWARE failed     : $FIRMWARE_FAIL"
    echo ""
    echo "BOOTLOADER successful : $BOOTLOADER_OK"
    echo "BOOTLOADER failed     : $BOOTLOADER_FAIL"
    echo ""
    echo "Security partitions excluded."
    echo "Userdata/data/cache excluded."
    echo ""
    echo "IMPORTANT:"
    echo "BOOTLOADER_REVIEW must not be flashed blindly."
    echo "Verify exact board/revision before PC flashing."
    echo ""
    echo "SHA256:"
    echo "$SHA"
    echo ""
    echo "=================================================="
    echo "BACKUP COMPLETE"
    echo "=================================================="
} | tee -a "$REPORT"

echo ""
echo "=============================================="
echo "BACKUP FINISHED"
echo "=============================================="
echo ""
echo "Backup location:"
echo "$OUT"
echo ""
echo "PC-তে নেওয়ার জন্য এই folder-এর ভিতরে থাকবে:"
echo ""
echo "BOOT/"
echo "FIRMWARE/"
echo "BOOTLOADER_REVIEW/"
echo "SECURITY_REVIEW/"
echo "HARDWARE.txt"
echo "partition-list.txt"
echo "FIRMWARE_MANIFEST.txt"
echo "FLASH_CANDIDATES.txt"
echo "SHA256SUMS"
echo "BACKUP_REPORT.txt"
echo ""
echo "Termux থেকে flash/restore করার কোনো feature নেই।"
echo "PC-তে পরে appropriate vendor flashing tool ব্যবহার করবেন।"
