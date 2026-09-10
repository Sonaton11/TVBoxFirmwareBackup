# TVBoxFirmwareBackup
TV Box firmware backup tool
📺 TV Box Firmware Backup Tool

Termux ব্যবহার করে Android TV Box থেকে firmware backup নেওয়ার জন্য এই tool।

«⚠️ Important: এই tool শুধুমাত্র Backup করার জন্য। Termux থেকে কোনো Restore বা Flash করা হয় না। Backup নেওয়ার পর PC-তে appropriate/vendor flashing tool ব্যবহার করে firmware flash করতে হবে।»

---

📋 Requirements

যা লাগবে:

- Android Phone
- Termux
- TV Box
- TV Box-এ ADB access
- Root access on TV Box
- Phone-এ পর্যাপ্ত free storage
- Wi-Fi ADB অথবা USB ADB

---

🚀 Step 1 — GitHub থেকে Repository Download করুন

Termux খুলুন।

প্রথমে package update করুন:

pkg update

তারপর Git এবং ADB install করুন:

pkg install git android-tools

---

📥 Step 2 — GitHub Repository Clone করুন

Home directory-তে যান:

cd ~

তারপর repository clone করুন:

git clone https://github.com/YOUR-GITHUB-USERNAME/TVBoxFirmwareBackup.git

«"YOUR-GITHUB-USERNAME" এর জায়গায় repository owner-এর GitHub username লিখুন।»

Repository folder-এ ঢুকুন:

cd TVBoxFirmwareBackup

ফাইলগুলো দেখুন:

ls

এখানে অবশ্যই দেখতে হবে:

backup.sh
README.md

---

🔐 Step 3 — Backup Script চালানোর Permission দিন

প্রথমবার শুধু একবার:

chmod +x backup.sh

---

📱 Step 4 — Phone Storage Permission দিন

Termux-কে Phone storage access দিন:

termux-setup-storage

Android permission চাইলে:

Allow চাপুন।

তারপর পরীক্ষা করুন:

ls /sdcard

Phone storage-এর ফাইল/ফোল্ডার দেখা গেলে storage permission ঠিক আছে।

---

📺 Step 5 — TV Box-এ ADB চালু করুন

TV Box-এ:

Developer Options → USB Debugging / ADB Debugging → ON

Wi-Fi ADB ব্যবহার করলে TV Box এবং Phone একই Wi-Fi network-এ থাকতে হবে।

উদাহরণ:

TV Box IP:
192.168.0.211

Termux থেকে:

adb connect 192.168.0.211:5555

তারপর:

adb devices

সঠিকভাবে connected হলে এমন দেখা যাবে:

192.168.0.211:5555    device

যদি প্রথমবার authorization message TV Box-এ আসে, তাহলে Allow দিন।

---

🔍 Step 6 — ADB Connection পরীক্ষা করুন

চালান:

adb shell

TV Box-এর shell খুললে:

exit

দিয়ে বের হয়ে আসুন।

তারপর:

adb devices

আবার নিশ্চিত করুন যে device-এর পাশে:

device

লেখা আছে।

---

💾 Step 7 — Firmware Backup শুরু করুন

Repository folder-এর ভিতরে থাকুন:

cd ~/TVBoxFirmwareBackup

তারপর:

./backup.sh

এখন script নিজে থেকে TV Box-এর information এবং partition layout পড়বে।

---

🤖 Script কী কী করবে?

Script automatically:

- TV Box-এর Manufacturer পড়বে
- Model পড়বে
- Board পড়বে
- Hardware পড়বে
- SoC/Platform information পড়বে
- Android version পড়বে
- CPU ABI পড়বে
- Partition layout পড়বে
- Boot partition শনাক্ত করবে
- Android firmware partition শনাক্ত করবে
- Dynamic "super" partition থাকলে শনাক্ত করবে
- Bootloader partition আলাদা করে শনাক্ত করবে
- SHA256 checksum তৈরি করবে
- Backup report তৈরি করবে

---

🛡️ কোন Data Backup করা হবে না?

Device-specific data সাধারণ firmware backup-এর অংশ হিসেবে নেওয়া হবে না।

যেমন:

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
serial-related data

এগুলো অন্য TV Box-এ ব্যবহার করার জন্য নয়।

---

⚠️ Bootloader সম্পর্কে গুরুত্বপূর্ণ

কিছু TV Box-এ boot করার জন্য bootloader partition প্রয়োজন হতে পারে।

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

এগুলো সাধারণ firmware partition থেকে আলাদা করে রাখা হবে:

BOOTLOADER_REVIEW/

«⚠️ BOOTLOADER_REVIEW-এর কোনো image অন্য Box-এ সরাসরি flash করবেন না।»

Exact:

- Model
- Board
- Hardware revision
- SoC
- Storage type
- Vendor

মিলিয়ে PC flashing-এর আগে যাচাই করতে হবে।

---

📂 Step 8 — Backup কোথায় পাওয়া যাবে?

Backup Phone-এর internal storage-এ সরাসরি তৈরি হবে:

/sdcard/TVBoxFirmware/

এর ভিতরে timestamp সহ folder তৈরি হবে:

TVBOX_YYYYMMDD_HHMMSS/

উদাহরণ:

/sdcard/TVBoxFirmware/TVBOX_20260910_163000/

---

📁 Backup Folder Structure

Backup শেষ হলে folder-এর ভিতরে থাকবে:

TVBOX_YYYYMMDD_HHMMSS/
│
├── BOOT/
│   ├── boot.img
│   ├── recovery.img
│   ├── vendor_boot.img
│   ├── init_boot.img
│   ├── dtbo.img
│   └── vbmeta.img
│
├── FIRMWARE/
│   ├── super.img
│   ├── system.img
│   ├── vendor.img
│   ├── product.img
│   ├── odm.img
│   └── system_ext.img
│
├── BOOTLOADER_REVIEW/
│   ├── preloader.img
│   ├── u-boot.img
│   ├── lk.img
│   ├── abl.img
│   └── ...
│
├── SECURITY_REVIEW/
│
├── HARDWARE.txt
├── partition-list.txt
├── FIRMWARE_MANIFEST.txt
├── FLASH_CANDIDATES.txt
├── SHA256SUMS
└── BACKUP_REPORT.txt

«আপনার TV Box-এর partition layout অনুযায়ী সব file থাকবে না। কোনো partition না থাকলে সেটি automatically skip হবে।»

---

🔎 Step 9 — Backup সফল হয়েছে কিনা পরীক্ষা করুন

Backup শেষ হওয়ার পরে:

ls /sdcard/TVBoxFirmware/

তারপর সর্বশেষ backup folder-এ ঢুকুন:

cd /sdcard/TVBoxFirmware/
ls

তারপর:

cd TVBOX_YYYYMMDD_HHMMSS

নিজের তৈরি timestamp অনুযায়ী folder-এর নাম ব্যবহার করুন।

তারপর:

cat BACKUP_REPORT.txt

Hardware information দেখতে:

cat HARDWARE.txt

Partition list দেখতে:

cat partition-list.txt

Flash candidate list দেখতে:

cat FLASH_CANDIDATES.txt

Checksum দেখতে:

cat SHA256SUMS

---

💻 Step 10 — PC-তে Backup নেওয়া

Backup সম্পূর্ণ হওয়ার পরে Phone থেকে পুরো folder PC-তে copy করুন।

উদাহরণ:

TVBOX_20260910_163000/

পুরো folder-টি রাখুন।

বিশেষ করে এগুলো হারাবেন না:

HARDWARE.txt
partition-list.txt
FLASH_CANDIDATES.txt
FIRMWARE_MANIFEST.txt
SHA256SUMS
BACKUP_REPORT.txt

---

⚡ PC থেকে Flash করার আগে

সরাসরি image flash করবেন না।

প্রথমে PC-তে:

1. "HARDWARE.txt" দেখুন
2. "partition-list.txt" দেখুন
3. Target TV Box-এর board/model/revision মিলান
4. Storage capacity মিলান
5. SoC/platform মিলান
6. Vendor flashing method নির্ধারণ করুন
7. "FLASH_CANDIDATES.txt" দেখুন
8. "BOOTLOADER_REVIEW" আলাদা করে যাচাই করুন
9. SHA256 দিয়ে backup files verify করুন

তারপর appropriate PC/vendor flashing tool ব্যবহার করুন।

---

🚫 এই Tool কী করে না?

এই project:

- ❌ Termux থেকে Restore করে না
- ❌ Termux থেকে Flash করে না
- ❌ অন্য Box-এ automatically firmware install করে না
- ❌ Device identity copy করার চেষ্টা করে না
- ❌ MAC/Serial/Userdata clone করে না
- ❌ Unknown partition blindly flash করার সিদ্ধান্ত নেয় না

---

🔐 Safety

Firmware backup নেওয়ার সময় source TV Box-এর original device-specific data সংরক্ষণ না করাই ভালো।

একই board/model/revision না মিললে backup অন্য TV Box-এ flash করবেন না।

বিশেষ করে:

BOOTLOADER_REVIEW/

এর files manually verify না করে flash করবেন না।

---

📌 Quick Start

যদি সব আগে থেকেই setup করা থাকে:

cd ~
git clone https://github.com/YOUR-GITHUB-USERNAME/TVBoxFirmwareBackup.git
cd TVBoxFirmwareBackup
chmod +x backup.sh
termux-setup-storage
adb connect TV_BOX_IP:5555
adb devices
./backup.sh

Backup পাবেন:

/sdcard/TVBoxFirmware/

---

📝 Important Note

এই tool partition layout দেখে conservativeভাবে firmware নির্বাচন করে।

সব Android TV Box একই partition structure ব্যবহার করে না।

তাই automatic detection মানেই 100% flash compatibility নয়।

PC-তে flash করার আগে source এবং target TV Box-এর hardware/board/revision অবশ্যই verify করতে হবে।
