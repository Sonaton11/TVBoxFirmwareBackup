📺 TV Box Firmware Backup Tool

🔧 Android TV Box Firmware Backup — Termux Based

এই Tool ব্যবহার করে Android Phone-এর Termux থেকে একটি working Android TV Box-এর firmware backup নেওয়া যাবে।

Backup সরাসরি Phone-এর storage-এ সংরক্ষণ হবে। পরে backup folder PC-তে নিয়ে গিয়ে appropriate/vendor flashing tool ব্যবহার করে compatible TV Box-এ firmware flash করা যাবে।

«🟢 Backup Only
🔴 No Restore / No Flash from Termux»

---

✨ Features

- 📱 Phone + Termux based
- 📺 Android TV Box ADB support
- 🔍 Automatic hardware information detection
- 🔍 Model / Board / SoC detection
- 💾 Automatic partition detection
- 🚀 Boot partition backup
- ⚙️ Android firmware partition backup
- 📦 "super.img" detection
- 🔧 Bootloader partitions আলাদা করে backup
- 🛡️ Device-specific partitions বাদ দেওয়া
- 🚫 Userdata / cache / personal data বাদ দেওয়া
- 🔐 Security-related partitions normal flash list থেকে বাদ
- 🧮 SHA256 checksum তৈরি
- 📋 Hardware report তৈরি
- 📋 Partition list তৈরি
- 📋 Flash candidate list তৈরি
- 📑 Complete backup report

---

📋 Requirements

Phone

- Android Phone
- Termux
- পর্যাপ্ত storage

TV Box

- Working Android TV Box
- ADB enabled
- Root access
- Wi-Fi ADB অথবা USB ADB

---

🚀 Installation

1️⃣ Termux Install করুন

Phone-এ Termux খুলুন।

তারপর:

pkg update

ADB এবং Git install করুন:

pkg install git android-tools

---

📥 2️⃣ GitHub Repository Clone করুন

Home directory-তে যান:

cd ~

তারপর এই repository clone করুন:

git clone https://github.com/Sonaton11/TVBoxFirmwareBackup.git

Repository folder-এ ঢুকুন:

cd TVBoxFirmwareBackup

ফাইলগুলো দেখুন:

ls

সেখানে দেখতে পাবেন:

backup.sh
README.md

---

🔐 3️⃣ Backup Script Permission দিন

একবার চালান:

chmod +x backup.sh

---

📱 4️⃣ Phone Storage Permission দিন

Termux-কে storage permission দিতে:

termux-setup-storage

Android permission চাইলে:

✅ Allow

চাপুন।

তারপর পরীক্ষা করুন:

ls /sdcard

Phone storage-এর folder দেখা গেলে সব ঠিক আছে।

---

📺 5️⃣ TV Box ADB Connect করুন

TV Box-এ:

Developer Options → ADB / USB Debugging → ON

Wi-Fi ADB ব্যবহার করলে Phone এবং TV Box একই network-এ থাকতে হবে।

উদাহরণ:

TV Box IP: example :
192.168.0.211

Termux-এ:

adb connect 192.168.0.211:5555

তারপর:

adb devices

সঠিকভাবে connected হলে:

192.168.0.211:5555    device

দেখাবে।

---

🔍 6️⃣ ADB Connection Test

চালান:

adb shell

TV Box shell খুললে:

exit

তারপর আবার:

adb devices

Device-এর পাশে অবশ্যই:

device

থাকতে হবে।

---

💾 7️⃣ Firmware Backup শুরু করুন

Repository folder-এ থাকুন:

cd ~/TVBoxFirmwareBackup

তারপর:

./backup.sh

এখন Tool নিজে থেকে TV Box scan করবে।

---

🤖 Automatic Detection

Tool automatically পড়বে:

Manufacturer
Brand
Model
Device
Board
Hardware
Platform
SoC
Android Version
SDK
Build
CPU ABI
Kernel
Partition Layout

---

💽 Backup করা হবে

🟢 BOOT

Boot-related partitions:

boot
boot_a
boot_b
vendor_boot
init_boot
recovery
dtbo
vbmeta
vbmeta_system
vbmeta_vendor

TV Box-এ যেগুলো থাকবে শুধু সেগুলোই backup হবে।

---

🔵 FIRMWARE

Android firmware partitions:

super
system
system_a
system_b
system_ext
vendor
vendor_a
vendor_b
product
product_a
product_b
odm
odm_a
odm_b

যে partition TV Box-এ নেই সেটি automatically skip হবে।

---

🟡 BOOTLOADER_REVIEW

কিছু TV Box-এর boot করার জন্য bootloader প্রয়োজন হতে পারে।

যেমন:

preloader
u-boot
uboot
lk
abl
xbl
xbl_config
bootloader
spl
loader

এগুলো আলাদা folder-এ রাখা হবে:

BOOTLOADER_REVIEW/

⚠️ গুরুত্বপূর্ণ

এই folder-এর files অন্য Box-এ সরাসরি flash করা যাবে না।

আগে verify করতে হবে:

Model
Board
Hardware Revision
SoC
Storage
Vendor

সব compatible কিনা।

---

🔴 Device-Specific Data বাদ থাকবে

অন্য Box-এর identity বা personal/device-specific data clone করার জন্য Tool তৈরি করা হয়নি।

সাধারণভাবে বাদ থাকবে:

userdata
data
cache
metadata
persist
nvram
nvdata
efs
factory
frp
proinfo
calibration
device information
MAC-related data
Serial-related data

---

🔐 Security Partitions

Security-related partitions normal flash candidate হিসেবে রাখা হবে না।

যেমন:

tee
tz
trustzone
keymaster
keystore

এগুলো:

SECURITY_REVIEW/

এর মধ্যে শুধু information হিসেবে flag করা হবে।

«⚠️ Security-related data অন্য device-এ flash করা উচিত নয়।»

---

📂 Backup Location

Backup সরাসরি Phone-এর storage-এ যাবে:

/sdcard/TVBoxFirmware/

প্রতিবার নতুন timestamp folder তৈরি হবে।

উদাহরণ:

/sdcard/TVBoxFirmware/TVBOX_20260910_163000/

---

📁 Backup Structure

TVBOX_YYYYMMDD_HHMMSS/
│
├── 📁 BOOT/
│   ├── boot.img
│   ├── recovery.img
│   ├── vendor_boot.img
│   ├── init_boot.img
│   ├── dtbo.img
│   └── vbmeta.img
│
├── 📁 FIRMWARE/
│   ├── super.img
│   ├── system.img
│   ├── vendor.img
│   ├── product.img
│   ├── odm.img
│   └── system_ext.img
│
├── 📁 BOOTLOADER_REVIEW/
│
├── 📁 SECURITY_REVIEW/
│
├── 📄 HARDWARE.txt
├── 📄 partition-list.txt
├── 📄 FIRMWARE_MANIFEST.txt
├── 📄 FLASH_CANDIDATES.txt
├── 📄 SHA256SUMS
└── 📄 BACKUP_REPORT.txt

«সব TV Box-এ একই partition থাকে না। তাই আপনার Box-এর layout অনুযায়ী files কম-বেশি হতে পারে।»

---

🔎 Backup Check করুন

Backup শেষ হওয়ার পরে:

ls /sdcard/TVBoxFirmware/

Backup folder-এ যান:

cd /sdcard/TVBoxFirmware/TVBOX_YYYYMMDD_HHMMSS

Backup Report:

cat BACKUP_REPORT.txt

Hardware Information:

cat HARDWARE.txt

Partition List:

cat partition-list.txt

Flash Candidates:

cat FLASH_CANDIDATES.txt

SHA256:

cat SHA256SUMS

---

💻 PC-তে Backup নেওয়া

Backup শেষ হলে পুরো:

TVBOX_YYYYMMDD_HHMMSS/

folder Phone থেকে PC-তে copy করুন।

বিশেষ করে এগুলো সংরক্ষণ করুন:

HARDWARE.txt
partition-list.txt
FIRMWARE_MANIFEST.txt
FLASH_CANDIDATES.txt
SHA256SUMS
BACKUP_REPORT.txt

---

⚡ PC থেকে Flash

PC-তে নেওয়ার পরে আগে:

1. Hardware মিলান

Model
Board
SoC
Hardware Revision
Storage
Vendor

2. Partition layout মিলান

partition-list.txt

দেখুন।

3. Normal firmware candidates দেখুন

FLASH_CANDIDATES.txt

4. SHA256 verify করুন

SHA256SUMS

5. তারপর appropriate PC/vendor flashing tool ব্যবহার করুন।

---

🚫 Termux থেকে Flash করা হয় না

এই project ইচ্ছাকৃতভাবে:

❌ Restore নেই
❌ Flash নেই
❌ Erase command নেই
❌ Factory reset নেই
❌ Device identity clone নেই

Termux-এর কাজ শুধু:

TV Box
   ↓
ADB
   ↓
Partition Detection
   ↓
Backup
   ↓
Phone Storage
   ↓
PC
   ↓
Appropriate Flashing Tool

---

⚠️ Compatibility Warning

Automatic partition detection মানেই 100% flash compatibility নয়।

একই নামের TV Box হলেও board revision, SoC, storage layout, bootloader বা vendor configuration আলাদা হতে পারে।

তাই অন্য Box-এ firmware flash করার আগে অবশ্যই hardware compatibility যাচাই করুন।

বিশেষ করে:

BOOTLOADER_REVIEW/

এর files blindly flash করবেন না।

---

🧰 Quick Start

যদি সবকিছু আগে থেকেই installed থাকে:

cd ~
git clone https://github.com/Sonaton11/TVBoxFirmwareBackup.git
cd TVBoxFirmwareBackup
chmod +x backup.sh
termux-setup-storage
adb connect TV_BOX_IP:5555
adb devices
./backup.sh

Backup পাওয়া যাবে:

/sdcard/TVBoxFirmware/

---

📌 Project

GitHub Repository

"Sonaton11/TVBoxFirmwareBackup" (https://github.com/Sonaton11/TVBoxFirmwareBackup?utm_source=chatgpt.com)

📺 TV Box → 📱 Phone → 💻 PC

Backup once. Verify carefully. Flash safely.
