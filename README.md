📺 TV Box Firmware Backup Tool

🔧 Android TV Box Firmware Backup — Termux Based

এই Tool ব্যবহার করে Android Phone-এর Termux থেকে একটি working Android TV Box-এর firmware backup নেওয়া যাবে।

Backup সরাসরি Phone-এর storage-এ সংরক্ষণ হবে। পরে backup folder PC-তে নিয়ে গিয়ে compatible TV Box-এর জন্য appropriate/vendor flashing tool ব্যবহার করে firmware flash করা যাবে।

«🟢 Backup Only
🔴 No Restore / No Flash from Termux»

---

✨ Features

- 📱 Android Phone + Termux
- 📺 Android TV Box ADB support
- 🔍 Automatic hardware information detection
- 🔍 Model / Board / SoC detection
- 💾 Automatic partition detection
- 🚀 Boot partition backup
- ⚙️ Android firmware partition backup
- 📦 "super.img" detection
- 🔧 Bootloader partition backup
- 🛡️ Device-specific partition exclusion
- 🚫 Userdata / personal data exclusion
- 🔐 Security-related partition exclusion
- 🧮 SHA256 checksum generation
- 📋 Hardware report
- 📋 Partition list
- 📋 Firmware manifest
- 📋 Flash candidate list
- 📑 Complete backup report

---

📋 Requirements

📱 Phone

- Android Phone
- Termux
- পর্যাপ্ত free storage
- ADB support

📺 TV Box

- Working Android TV Box
- ADB enabled
- Root access
- Wi-Fi ADB অথবা USB ADB

---

🚀 Step 1 — Termux Setup

📦 Termux Setup

Termux খুলে নিচের একটি Code Box-এর সব command একসাথে Copy করে Paste করুন:
```bash
pkg update -y
pkg upgrade -y
pkg install -y git android-tools
termux-setup-storage
```

"termux-setup-storage" চালানোর পরে Android permission চাইলে Allow চাপুন।

তারপর পরীক্ষা করুন:
```bash
ls /sdcard
```
Phone storage-এর files/folders দেখা গেলে storage permission ঠিক আছে।

---

📥 Step 2 — GitHub থেকে Tool Install

নিচের command-টি একবারে Copy → Paste → Enter করুন:
```bash
cd ~ &&git clone https://github.com/Sonaton11/TVBoxFirmwareBackup.git && cd TVBoxFirmwareBackup && chmod +x backup.sh
```
সব ঠিক থাকলে repository folder-এর ভিতরে চলে যাবেন।

ফাইল পরীক্ষা করুন:
```bash
ls
```
দেখতে পাবেন:

backup.sh
README.md

---

📺 Step 3 — TV Box-এ ADB চালু করুন

TV Box-এ:

Settings → Developer Options → ADB / USB Debugging → ON

Wi-Fi ADB ব্যবহার করলে Phone এবং TV Box একই Wi-Fi network-এ থাকতে হবে।

উদাহরণ:

TV Box IP:example :
192.168.0.217

Termux-এ:
```bash
adb connect 192.168.0.217:5555
```
তারপর:
```bash
adb devices
```
সঠিকভাবে connected হলে:

192.168.0.217:5555    device

দেখাবে।

«"192.168.0.217" শুধু উদাহরণ। আপনার TV Box-এর নিজের IP ব্যবহার করবেন।»

---

🔍 Step 4 — ADB Connection Test

চালান:
```bash
adb shell
```
TV Box shell খুললে:
```bash
exit
```
তারপর:
```bash
adb devices
```
Device-এর পাশে অবশ্যই:
```bash
device
```
থাকতে হবে।

---

🔐 Step 5 — Root Access Check

এই Tool protected firmware partitions পড়ার জন্য TV Box-এর root access ব্যবহার করে।

Test করতে:
```bash
adb shell su -c id
```
সঠিক হলে এরকম দেখা যাবে:

uid=0(root)

যদি "uid=0(root)" না আসে, তাহলে complete firmware backup সম্ভব নাও হতে পারে।

---

💾 Step 6 — Firmware Backup শুরু করুন

Repository folder-এ যান:
```bash
cd ~/TVBoxFirmwareBackup
```
তারপর:
```bash
./backup.sh
```
এখন Tool automatically TV Box scan করবে।

---

🤖 Tool কী কী Automatically Detect করবে?

Tool TV Box থেকে পড়বে:

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

তারপর partition অনুযায়ী backup category তৈরি করবে।

---

🟢 BOOT — Boot Partitions

Boot-related partitions থাকলে backup করা হবে:

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
vbmeta_vendor

TV Box-এ যে partition থাকবে শুধু সেটিই backup হবে।

---

🔵 FIRMWARE — Android Firmware

Android firmware-related partitions থাকলে backup করা হবে:

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

যে partition TV Box-এ নেই সেটি automatically skip হবে।

---

🟡 BOOTLOADER_REVIEW

কিছু TV Box-এর জন্য bootloader firmware-এর গুরুত্বপূর্ণ অংশ হতে পারে।

Common examples:

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

"BOOTLOADER_REVIEW"-এর image অন্য TV Box-এ blindly flash করবেন না।

Flash করার আগে অবশ্যই verify করুন:

Model
Board
Hardware Revision
SoC
Storage
Vendor

---

🔴 Device-Specific Data Excluded

অন্য Box-এর device identity বা personal data clone করার জন্য এই Tool তৈরি করা হয়নি।

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

🔐 Security-Related Partitions

Security-related partitions normal firmware candidate হিসেবে ব্যবহার করা হবে না।

যেমন:

tee
tz
trustzone
keymaster
keystore

এগুলো "SECURITY_REVIEW/"-এ information হিসেবে flag করা হবে।

«⚠️ Security-related data অন্য device-এ flash করা উচিত নয়।»

---

📦 Dynamic Partition — super.img

যদি TV Box-এ:

super

partition থাকে, Tool সেটিকে backup করবে:

FIRMWARE/super.img

"super.img" অনেক Android device-এ system/vendor/product ইত্যাদি logical partition-এর container হিসেবে ব্যবহৃত হতে পারে।

---

📂 Step 7 — Backup Location

Backup Phone-এর internal storage-এ সরাসরি তৈরি হবে:

/sdcard/TVBoxFirmware/

প্রতিবার নতুন timestamp folder তৈরি হবে।

উদাহরণ:

/sdcard/TVBoxFirmware/TVBOX_20260910_163000/

---

📁 Backup Folder Structure

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

🔎 Step 8 — Backup Check করুন

Backup শেষ হলে:
```bash
ls /sdcard/TVBoxFirmware/
```
তারপর আপনার backup folder-এ যান:
```bash
cd /sdcard/TVBoxFirmware/TVBOX_YYYYMMDD_HHMMSS
```
📋 Backup Report
```bash
cat BACKUP_REPORT.txt
```
🔧 Hardware Information
```bash
cat HARDWARE.txt
```
💽 Partition List
```bash
cat partition-list.txt
```
⚡ Flash Candidates
```bash
cat FLASH_CANDIDATES.txt
```
🔐 SHA256 Checksum
```bash
cat SHA256SUMS
```
---

💻 Step 9 — PC-তে Backup Copy করুন

Backup complete হওয়ার পরে পুরো folder:

TVBOX_YYYYMMDD_HHMMSS/

Phone থেকে PC-তে copy করুন।

বিশেষ করে এগুলো অবশ্যই রাখুন:
```bash
HARDWARE.txt
partition-list.txt
FIRMWARE_MANIFEST.txt
FLASH_CANDIDATES.txt
SHA256SUMS
BACKUP_REPORT.txt
```
---

⚡ Step 10 — PC থেকে Flash করার আগে

PC-তে নেওয়ার পর সরাসরি কোনো image flash করবেন না।

প্রথমে:

1️⃣ Hardware মিলান

Model
Board
SoC
Hardware Revision
Storage
Vendor

2️⃣ Partition layout মিলান

partition-list.txt

3️⃣ Firmware candidates দেখুন

FLASH_CANDIDATES.txt

4️⃣ Backup integrity verify করুন

SHA256SUMS

5️⃣ তারপর compatible PC/vendor flashing tool নির্বাচন করুন।

---

🚫 Termux থেকে Flash করা হয় না

এই project ইচ্ছাকৃতভাবে:

❌ Restore নেই
❌ Flash নেই
❌ Erase command নেই
❌ Factory reset নেই
❌ Device identity clone নেই

Termux-এর কাজ:

📺 TV Box
     │
     ▼
   ADB
     │
     ▼
Partition Detection
     │
     ▼
Firmware Backup
     │
     ▼
📱 Phone Storage
     │
     ▼
💻 PC
     │
     ▼
Appropriate Flashing Tool

---

⚠️ Compatibility Warning

Automatic partition detection মানেই 100% flash compatibility নয়।

একই model-এর TV Box হলেও:

- Board revision
- SoC
- Storage type
- Partition layout
- Bootloader
- Vendor configuration

আলাদা হতে পারে।

তাই অন্য Box-এ firmware flash করার আগে source এবং target Box-এর hardware compatibility অবশ্যই যাচাই করুন।

বিশেষ সতর্কতা

BOOTLOADER_REVIEW/

এর files blindly flash করবেন না।

---

🛠️ Quick Start

যদি Termux setup আগে থেকেই করা থাকে:
```bash
cd ~ && git clone https://github.com/Sonaton11/TVBoxFirmwareBackup.git && cd TVBoxFirmwareBackup && chmod +x backup.sh
```
TV Box connect করুন:
```bash
adb connect TV_BOX_IP:5555
```
Check করুন:
```bash
adb devices
```
তারপর backup:
```bash
cd ~/TVBoxFirmwareBackup && ./backup.sh
```
Backup পাওয়া যাবে:
```bash
/sdcard/TVBoxFirmware/
```
---

🔄 Update Tool

Repository থেকে নতুন version নেওয়ার জন্য:
```bash
cd ~/TVBoxFirmwareBackup && git pull
```
তারপর:
```bash
chmod +x backup.sh
```
এবং backup চালান:
```bash
./backup.sh
```
---

📌 Important Notes

- 🔹 Backup করার সময় TV Box বন্ধ করবেন না।
- 🔹 Backup চলার সময় ADB connection বিচ্ছিন্ন করবেন না।
- 🔹 Phone-এ পর্যাপ্ত free storage রাখুন।
- 🔹 বড় "super.img" backup হতে অনেক storage লাগতে পারে।
- 🔹 Backup সম্পূর্ণ হওয়ার আগে TV Box disconnect করবেন না।
- 🔹 Backup নেওয়া মানেই target Box-এ firmware flash করার নিশ্চয়তা নয়।
- 🔹 PC flashing-এর জন্য target Box-এর exact compatibility যাচাই করা প্রয়োজন।
- 🔹 Bootloader files বিশেষভাবে সতর্কতার সঙ্গে ব্যবহার করতে হবে।

---

📜 License

এই project-এর উদ্দেশ্য হলো নিজের/অনুমোদিত Android TV Box firmware-এর backup এবং analysis সহজ করা।

Firmware-এর ownership এবং redistribution-এর দায়িত্ব ব্যবহারকারীর।

---

📺 Project

TVBoxFirmwareBackup

GitHub Repository:

"Sonaton11/TVBoxFirmwareBackup" (https://github.com/Sonaton11/TVBoxFirmwareBackup)

---

🟢 Backup → Verify → PC → Flash

Backup safely. Verify hardware carefully. Flash only compatible devices.
