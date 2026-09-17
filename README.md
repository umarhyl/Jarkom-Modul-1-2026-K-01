# JARKOM MODUL 1 2026 - K01

## Member

| Nama | NRP |
| --- | --- |
| Umar | 5027251005 |
| Syarifah Nailatur Rohma | 5027251109 |

## Laporan

1. Untuk mempersiapkan pembangunan The Wired, Lain yang berperan sebagai Router membuat tiga Switch/Gateway: Switch 1 menuju dua Entitas yaitu Alice dan Mika, Switch 2 menuju Chisa, sedangkan Switch 3 menuju Knights dan Eiri. Kelima Entitas tersebut dikonfigurasi sebagai Client di GNS3.

Pertama, dibuat topologi jaringan sesuai dengan pembagian node pada soal. Lain menjadi router yang menghubungkan ketiga segmen jaringan, sedangkan kelima entitas menjadi client pada switch masing-masing.

![topology](assets/topology.png)

Komponen yang digunakan pada topologi tersebut adalah sebagai berikut:

- **NAT:** menyediakan koneksi menuju internet dan layanan DHCP untuk interface luar Lain.
- **Router Lain:** menghubungkan jaringan internet dengan ketiga subnet client, menggunakan image `debinet`.
- **Switch 1:** menghubungkan Alice dan Mika dengan interface LAN Lain pada segmen pertama.
- **Switch 2:** menghubungkan Chisa dengan interface LAN Lain pada segmen kedua.
- **Switch 3:** menghubungkan Knights dan Eiri dengan interface LAN Lain pada segmen ketiga.
- **Client:** Alice, Mika, Chisa, Knights, dan Eiri menggunakan image `alpinet`.

Prefix IP kelompok kami adalah `10.64.X.X`. Pembagian subnet dan gateway yang digunakan adalah sebagai berikut. Alamat gateway dikonfigurasi pada interface router Lain yang terhubung ke masing-masing switch.

| Segmen | Client | Subnet | Gateway pada Lain |
| --- | --- | --- | --- |
| Switch 1 | Alice, Mika | 10.64.1.0/24 | 10.64.1.1 |
| Switch 2 | Chisa | 10.64.2.0/24 | 10.64.2.1 |
| Switch 3 | Knights, Eiri | 10.64.3.0/24 | 10.64.3.1 |


2. Karena menurut Lain pada saat itu The Wired masih terisolasi dari dunia luar, konfigurasikan router Lain agar dapat tersambung langsung ke jaringan internet publik melalui NAT/DHCP pada interface eth0.

Untuk membuat Lain terhubung ke internet, interface **eth0** yang terhubung dengan NAT dikonfigurasi agar memperoleh alamat IP melalui DHCP. Konfigurasi yang digunakan pada file `/etc/network/interfaces` adalah sebagai berikut:

```text
auto eth0
iface eth0 inet dhcp
```

Setelah konfigurasi diterapkan, alamat interface dan default route diperiksa menggunakan `ip -br a` dan `ip route`.

![lain dhcp](assets/lain-dhcp.png)

Selanjutnya dilakukan pengujian koneksi dari Lain ke `8.8.8.8` untuk memastikan router dapat menjangkau jaringan internet.

![lain internet](assets/lain-internet.png)

3. Setelah router Lain terhubung ke internet, pastikan seluruh Entitas (Client) di bawah Switch 1, Switch 2, dan Switch 3 dapat saling terhubung dan berkomunikasi satu sama lain melalui konfigurasi routing.

Agar seluruh client dapat berkomunikasi, setiap interface LAN pada Lain diberikan alamat IP statis yang menjadi gateway bagi subnet terkait. Konfigurasi interface LAN Lain adalah sebagai berikut:

```text
auto eth1
iface eth1 inet static
    address 10.64.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 10.64.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 10.64.3.1
    netmask 255.255.255.0
```

![lain ip lan](assets/lain-ip-lan.png)

Selanjutnya, masing-masing client diberikan alamat IP statis dan default gateway sesuai dengan segmennya. Konfigurasi yang digunakan pada setiap node adalah sebagai berikut:

**Alice**

```text
auto eth0
iface eth0 inet static
    address 10.64.1.2
    netmask 255.255.255.0
    gateway 10.64.1.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

**Mika**

```text
auto eth0
iface eth0 inet static
    address 10.64.1.3
    netmask 255.255.255.0
    gateway 10.64.1.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

**Chisa**

```text
auto eth0
iface eth0 inet static
    address 10.64.2.2
    netmask 255.255.255.0
    gateway 10.64.2.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

**Knights**

```text
auto eth0
iface eth0 inet static
    address 10.64.3.2
    netmask 255.255.255.0
    gateway 10.64.3.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

**Eiri**

```text
auto eth0
iface eth0 inet static
    address 10.64.3.3
    netmask 255.255.255.0
    gateway 10.64.3.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

![client ip route](assets/client-ip-route.png)

Pada Lain, IP forwarding diaktifkan agar paket dapat diteruskan antarinterface. Jika terdapat pembatasan firewall, aturan FORWARD disesuaikan agar trafik antarsegmen diizinkan.

```text
sysctl -w net.ipv4.ip_forward=1
```

![lain routing](assets/lain-routing.png)

Ketiga subnet LAN merupakan jaringan yang terhubung langsung ke Lain, sehingga route menuju subnet tersebut tercatat sebagai connected routes. Client menggunakan default gateway untuk mencapai subnet lain. Selanjutnya dilakukan ping dari setiap client menuju empat client lainnya.

![ping others](assets/ping-others.png)

4. Lain ingin agar setiap Entitas (Client) memiliki kemandirian di The Wired. Konfigurasikan firewall/iptables (NAT Masquerade) dan DNS resolver agar setiap Client dapat terhubung ke internet secara mandiri (dapat melakukan ping ke 192.168.122.1 dan membuka domain web google.com).

Untuk memberikan akses internet kepada seluruh client, dilakukan konfigurasi NAT Masquerade pada Lain. Aturan ini mengganti alamat sumber paket dari jaringan client dengan alamat interface keluar Lain, yaitu **eth0**.

```text
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth0 -j ACCEPT
```

![lain nat](assets/lain-nat.png)

Selanjutnya dilakukan konfigurasi DNS resolver pada masing-masing client agar nama domain dapat diterjemahkan menjadi alamat IP. Resolver yang digunakan adalah `192.168.122.1` dengan konfigurasi berikut, lalu dilakukan pengujian koneksi ke internet.

```text
up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

![client dns internet](assets/client-dns-internet.png)

5. Eiri tetap berupaya menanamkan kekacauan ke dalam jaringan. Untuk mengantisipasi restart tiba-tiba, pastikan seluruh konfigurasi jaringan tidak hilang saat semua node di-restart. Buat script verifikasi di /root/cek_status.sh pada router Lain yang menampilkan ringkasan interface (ip -br a) dan status tabel NAT (iptables -t nat -L -v -n) setelah reboot.

Agar konfigurasi tetap berlaku setelah restart, pengaturan interface, route, DNS, IP forwarding, dan aturan iptables disimpan melalui mekanisme startup yang digunakan pada node.

**Lain**

```bash
#!/bin/bash

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 10.64.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 10.64.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 10.64.3.1
    netmask 255.255.255.0
EOF

apt update
which iptables &>/dev/null || apt install iptables -y

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth0 -j ACCEPT

/root/cek_status.sh
```

**Client**

```bash
<!-- Alice -->
#!/bin/sh

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.64.1.2
    netmask 255.255.255.0
    gateway 10.64.1.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

<!-- Mika -->
#!/bin/sh

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.64.1.3
    netmask 255.255.255.0
    gateway 10.64.1.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

<!-- Chisa -->
#!/bin/sh

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.64.2.2
    netmask 255.255.255.0
    gateway 10.64.2.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

<!-- Knights -->
#!/bin/sh

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.64.3.2
    netmask 255.255.255.0
    gateway 10.64.3.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF
#
<!-- Eiri -->
#!/bin/sh

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.64.3.3
    netmask 255.255.255.0
    gateway 10.64.3.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF
```

Kemudian dibuat script `/root/cek_status.sh` pada Lain untuk memeriksa alamat interface dan tabel NAT setelah node dinyalakan kembali.

```bash
#!/bin/sh

sysctl -w net.ipv4.ip_forward=1

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth0 -j ACCEPT
```

![lain after restart](assets/lain-after-restart.png)

6. Mika mencurigai adanya anomali traffic pada segmen jaringannya. Jalankan generator traffic berikut ([link file](https://drive.google.com/drive/folders/1ZjFvWIjvAQAjE9pPthm7V_bGyaSt93lY?usp=sharing)) pada node Mika, lalu lakukan packet sniffing menggunakan Wireshark pada interface node Mika. Terapkan display filter khusus untuk menyaring paket yang berprotokol DNS atau ICMP. Tunjukkan screenshot hasil filter beserta ringkasan paket yang lolos.

File [`traffic_protocol7.sh`](artefacts/traffic_protocol7.sh) dijalankan pada Mika untuk menghasilkan traffic DNS dan ICMP. Berikut isi script tersebut.

```bash
#!/bin/bash
# ============================================
# Traffic Generator — Protocol 7 Network
# Serial Experiments Lain — Modul 1 Jarkom 2026
# Jalankan di node MIKA untuk generate traffic DNS & ICMP
# ============================================

echo "============================================"
echo "  Protocol 7 Traffic Generator v2026"
echo "  Node: Mika Iwakura"
echo "============================================"
echo "[*] Generating DNS & ICMP traffic..."

# ICMP Traffic
ping -c 5 8.8.8.8 &
ping -c 5 1.1.1.1 &
ping -c 3 its.ac.id &

# DNS Queries
nslookup google.com 8.8.8.8 &
nslookup its.ac.id 8.8.8.8 &
nslookup github.com 1.1.1.1 &
dig @8.8.8.8 example.com A &
dig @1.1.1.1 cloudflare.com AAAA &

wait
echo "[*] Traffic generation complete."
echo "[*] Check Wireshark for captured packets."
```

![mika start traffic](assets/mika-start-traffic.gif)

Pada Wireshark diterapkan display filter berikut:

```text
dns || icmp
```

Filter tersebut menampilkan paket DNS atau ICMP. DNS digunakan untuk mengamati resolusi nama, sedangkan ICMP dapat memperlihatkan pesan seperti Echo Request dan Echo Reply.

![mika dns icmp](assets/mika-dns-icmp.png)

Ringkasan paket yang lolos filter adalah sebagai berikut:

| Protokol |          Jumlah paket | Sumber dan tujuan                                         | Informasi paket                                                                                                                                |
| -------- | --------------------: | --------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| DNS      | **22 packet** | Mika ↔ `8.8.8.8`, Mika ↔ `1.1.1.1`                        | Query/response `its.ac.id`, `example.com`, `github.com`, `cloudflare.com`, dan `google.com`. Record yang terlihat meliputi **A** dan **AAAA**. |
| ICMP     |          **26 paket** | Mika ↔ `8.8.8.8`, Mika ↔ `1.1.1.1`, Mika ↔ `103.94.189.4` | ICMP **Echo Request (Type 8, Code 0)** dan **Echo Reply (Type 0, Code 0)** dengan pola request–reply.                                          |

file capture: [`mika-capture-icmp-dns.pcapng`](./captures/capture_mika_icmp_dns.pcapng).

7. Chisa memutuskan mendirikan FTP Server pada node miliknya dengan shared folder di /var/wired/data. Terapkan kebijakan akses: user alice (hak akses read & write), user mika (dibatasi read-only), dan user eiri (dibatasi tanpa izin akses / blacklist). Buktikan konfigurasi dengan membuat file signal_alice.txt dari user alice, dan buktikan penolakan akses saat user eiri mencoba login.

Pertama dilakukan instalasi FTP server pada Chisa menggunakan `vsftpd`. Kemudian dibuat direktori `/var/wired/data` sebagai shared folder dan akun yang diperlukan untuk pengujian.

```bash
apk update
apk add vsftpd

id alice >/dev/null 2>&1 || adduser -D alice
echo "alice:alice123" | chpasswd

id mika >/dev/null 2>&1 || adduser -D mika
echo "mika:mika123" | chpasswd

id eiri >/dev/null 2>&1 || adduser -D eiri
echo "eiri:eiri123" | chpasswd

mkdir -p /var/wired/data

chown alice:alice /var/wired/data
chmod 755 /var/wired/data
```

Selanjutnya dilakukan pengaturan layanan FTP beserta kebijakan akses setiap user. Akun alice diberi hak baca dan tulis, mika hanya diberi hak baca, sedangkan eiri dimasukkan ke blacklist agar login ditolak.

```text
<!-- /etc/vsftpd.conf -->
listen=YES
listen_address=0.0.0.0
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_root=/var/wired/data
chroot_local_user=YES
allow_writeable_chroot=YES
user_config_dir=/etc/vsftpd/users
userlist_enable=YES
userlist_deny=YES
userlist_file=/etc/vsftpd/user_list
pasv_enable=YES
pasv_min_port=30000
pasv_max_port=30100
local_umask=022
seccomp_sandbox=NO

<!-- /etc/vsftpd/users/alice -->
write_enable=YES

<!-- /etc/vsftpd/users/mika -->
write_enable=NO

<!-- /etc/vsftpd/users_list -->
eiri

<!-- restart vsftpd -->
pkillall vsftpd
vsftpd /etc/vsftpd.conf &
```

Lalu, dilakukan pengujian menggunakan akun **alice** untuk membuat atau mengunggah `signal_alice.txt` melalui FTP.

```bash
lftp -u alice,alice123 10.64.2.2

put signal_alice.txt
ls
```

![ftp alice write](assets/ftp-alice-write.png)

Berikutnya dilakukan percobaan login menggunakan akun **eiri**.

![ftp eiri denied](assets/ftp-eiri-denied.png)

8. Kelompok rahasia Knights perlu mengirimkan dokumen laporan intelijen ke FTP Server Chisa. Lakukan koneksi FTP client dari node Knights ke FTP Server Chisa menggunakan akun alice. Upload file berikut ([link file](https://drive.google.com/drive/folders/1tvZpueSH9E3GWwXM6KNnM64Y5wNoIAYP?usp=sharing)). Analisis sesi Wireshark dan sebutkan: perintah FTP untuk upload (STOR), kode status sukses server (226), dan port data TCP yang dinegosiasikan pada mode PASV.

File [`knights_report.txt](artefacts/knights_report.txt). Selanjutnya dilakukan koneksi ke FTP server Chisa menggunakan akun alice dan mode PASV.

```bash
lftp -u alice,alice123 ftp://10.64.2.2
set ftp:passive-mode true
```

![knights ftp upload](assets/knights-ftp-upload.gif)

Pada Wireshark, FTP diperiksa untuk menemukan perintah `PASV`, respons `227`, perintah `STOR`, serta respons `226` yang berkaitan dengan transfer dokumen.

![knights ftp pasv](assets/knights-ftp-pasv.png)

`STOR` merupakan perintah untuk menyimpan file pada server. Respons `226` menunjukkan penyelesaian transfer. Pada mode PASV, port data dihitung dari dua angka terakhir respons `227` dengan rumus `(p1 * 256) + p2`.

| Informasi | Hasil capture |
| --- | --- |
| Perintah upload dan nama file | STOR knights_report.txt |
| Respons penyelesaian transfer | 226 Transfer complete. |
| Respons PASV | 227 Entering Passive Mode (10,64,2,2,117,131). |
| Perhitungan port data | (117 × 256) + 131 = 30083 |
| IP:port client dan IP:port server pada kanal data | 10.64.3.2:50926 → 10.64.2.2:30083 |

![knights ftp data port](assets/knights-ftp-data-port.png)

file capture: [`knights-ftp-upload.pcapng`](./captures/knights_ftp_upload.pcapng)

9. Mika mengakses dokumen Protokol Tujuh di ([link file](https://drive.google.com/drive/folders/1S3hG0dnZBTkCta4uILWwKVc6dSYYGRJ6?usp=sharing)) dari FTP Server Chisa. Dari node Mika, unduh file tersebut menggunakan akun mika. Setelah itu, buktikan pembatasan read-only dengan mencoba mengunggah file baru dari akun mika, dan tunjukkan pesan error respon server (error 550 Permission denied) saat mika mencoba melakukan upload.

File [`protocol7_manifesto.txt`](artefacts/protocol7_manifesto.txt) ditaruh pada direktori `/var/wired/data` di node Chisa. 

Lalu, dari node Mika dilakukan login menggunakan akun mika dan download dokumen tersebut.

```bash
lftp -u mika,mika123 ftp://10.64.2.2
get protocol7_manifesto.txt
```

![mika ftp download](assets/mika-ftp-download.png)

Untuk menguji pembatasan read-only, dibuat file percobaan pada Mika dan dilakukan upload melalui akun yang sama.

```bash
lftp -u mika,mika123 ftp://10.64.2.2
put mika_upload_test.txt
```

![mika ftp readonly](assets/mika-ftp-readonly.png)

10. Knights melancarkan uji ketahanan koneksi ke server Chisa untuk menguji latensi jaringan The Wired. Kirimkan paket ping dari node Knights ke node Chisa dengan payload khusus 128 bytes dan interval 0.3 detik sebanyak 77 paket. Buka Wireshark, catat nilai ICMP Type dan Code untuk Echo Request vs Echo Reply, serta analisis packet loss dan RTT (min/avg/max).

Pengujian dilakukan dari Knights menuju Chisa menggunakan perintah berikut:

```bash
ping -c 77 -s 128 -i 0.3 10.64.2.2
```

- `-c 77`: mengirimkan 77 paket Echo Request.
- `-s 128`: menggunakan payload ICMP sebesar 128 bytes.
- `-i 0.3`: memberikan interval 0,3 detik antarpengiriman.

![knights ping chisa](assets/knights-ping-chisa.gif)

Pada saat pengujian berlangsung, capture dijalankan untuk mengamati paket ICMP. Filter yang digunakan adalah sebagai berikut:

```wireshark
icmp.type == 8 || icmp.type == 0
```
![icmp echo request](assets/icmp-echo-request.png)

![icmp echo reply](assets/icmp-echo-reply.png)

Ringkasan hasil pengujian adalah sebagai berikut:

| Parameter                 | Hasil    |
| ------------------------- | -------- |
| Paket dikirim             | 77 paket |
| Paket diterima            | 77 paket |
| Packet loss               | 0%       |
| RTT minimum               | 0.332 ms |
| RTT rata-rata             | 0.603 ms |
| RTT maksimum              | 1.241 ms |
| Echo Request: Type / Code | 8 / 0    |
| Echo Reply: Type / Code   | 0 / 0    |

RTT menunjukkan waktu perjalanan paket menuju tujuan dan kembali ke pengirim. Ukuran frame pada Wireshark lebih besar dari payload 128 bytes karena mencakup header protokol.

Berdasarkan hasil tersebut, kondisi koneksi Knights ke Chisa tergolong stabil. Seluruh 77 paket yang dikirim berhasil diterima kembali tanpa packet loss. Nilai RTT minimum sebesar 0.332 ms, rata-rata 0.603 ms, dan maksimum 1.241 ms menunjukkan bahwa komunikasi antar-node berlangsung dengan cepat dan memiliki latensi yang rendah.

file capture : [`knights_icmp_chisa.pcapng`](captures/knights_icmp_chisa.pcapng)

11. Buktikan kelemahan protokol Telnet dengan membuat akun phantom_user dan password wired_ghost pada layanan telnetd di node Chisa. Lakukan login Telnet dari node Eiri ke node Chisa dan tangkap sesi menggunakan Wireshark. Tunjukkan kredensial plain text melalui fitur Follow TCP Stream, serta jelaskan mengapa setiap karakter terkirim dalam paket TCP terpisah.

Secara default, telnetd udah ada di alpine, jadi hanya perlu akun `phantom_user` dengan password praktikum `wired_ghost`.

```text
# add user phantom_user
adduser -D phantom_user
echo "phantom_user:wired_ghost" | chpasswd

# run telnetd
telnetd -p 23 &
```

Selanjutnya dilakukan login Telnet dari Eiri menuju Chisa.

![eiri telnet chisa](assets/eiri-telnet-chisa.gif)

Pada Wireshark, dipilih salah satu paket sesi Telnet lalu dibuka menu **Follow > TCP Stream** untuk melihat aliran data sesi.

![telnet follow stream](assets/telnet-follow-stream.png)

Telnet tidak mengenkripsi sesi sehingga data autentikasi dapat dibaca dari hasil capture. Meskipun password tidak ditampilkan kembali pada terminal, karakter password tetap dikirim melalui jaringan.

file capture: [`eiri-telnet-chisa.pcapng`](captures/eiri_telnet_chisa.pcapng)

12. Alice mencurigai Knights menjalankan beberapa layanan rahasia di node-nya. Lakukan pemindaian port dari node Alice ke node Knights menggunakan Netcat (nc) untuk memeriksa port 22 (SSH) dan 80 (HTTP) dalam keadaan terbuka, serta port rahasia 7777 dalam keadaan tertutup. Analisis di Wireshark perbedaan TCP Flag yang dikembalikan antara port terbuka (SYN-ACK) dengan port tertutup (RST-ACK).

Jalankan layanan SSS dan HTTP pada Knights:

```bash
apk update
apk add openssh
ssh-keygen -A

id mika_admin >/dev/null 2>&1 || adduser -D mika_admin
echo "mika_admin:mika123" | chpasswd

sed -i \
    -e 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' \
    -e 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' \
    /etc/ssh/sshd_config

grep -q '^PubkeyAuthentication ' /etc/ssh/sshd_config ||
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config

grep -q '^PasswordAuthentication ' /etc/ssh/sshd_config ||
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

pkill sshd 2>/dev/null || true
/usr/sbin/sshd


# http (port 80)
mkdir -p /www
echo "Knights HTTP Server" > /www/index.html
httpd -p 80 -h /www
```

![knights listening ports](assets/knights-listening-ports.png)

Selanjutnya dilakukan pemeriksaan ketiga port dari Alice menggunakan Netcat, bersamaan dengan capture traffic menuju Knights.

```bash
nc -zv 10.64.3.2 22 80 7777
```

![alice nc knights](assets/alice-nc-knights.png)

filter wireshark

```wireshark
tcp.port == 22 || tcp.port == 80 || tcp.port == 7777
```

![knights port flags](assets/knights-open-closed-port-flags.png)

Port terbuka membalas permintaan SYN dengan SYN-ACK untuk memulai pembentukan koneksi TCP. Port tertutup umumnya membalas dengan RST-ACK sebagai penolakan koneksi. Jika paket dibuang oleh firewall tanpa balasan, hasilnya dapat berupa timeout dan bukan bukti respons RST-ACK.

file capture: [`alice-nc-knights.pcapng`](captures/alice_nc_knights.pcapng)

13. Lain memerintahkan agar administrasi jarak jauh menggunakan SSH secara aman tanpa password. Install OpenSSH server pada node Knights, buat pasangan kunci SSH (ssh-keygen) pada node Mika untuk user mika_admin, dan konfigurasikan public key authentication (PasswordAuthentication no). Lakukan koneksi SSH dari node Mika ke node Knights, tangkap sesi menggunakan Wireshark, identifikasi paket Protocol Version Exchange dan Key Exchange, serta jelaskan mengapa kredensial tidak terlihat dalam bentuk teks terbuka seperti pada Telnet.

Konfigurasi menggunakan script [`mika.sh`](nodes/mika/mika.sh) dan [`knights.sh`](nodes/knights/knights.sh). Copy public key dari Mika ke Knights menggunakan `ssh-copy-id` atau metode lain, lalu ubah konfigurasi SSH server pada Knights untuk menonaktifkan autentikasi password. Setelah public key Mika dipasang pada Knights dan `PasswordAuthentication no` diterapkan, pengujian dilakukan sebagai berikut.

```bash
<!-- di Knights -->
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEd7foBvYXWw7Tk6N5ioPUqBo7QmyidS4X6tKMMHrqXe root@mika" > /home/mika_admin/.ssh/authorized_keys
chown mika_admin:mika_admin /home/mika_admin/.ssh/authorized_keys
chmod 600 /home/mika_admin/.ssh/authorized_keys

sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

pkill sshd 2>/dev/null || true
/usr/sbin/sshd

<!-- di Mika -->
ssh mika_admin@10.64.3.2
```

![mika ssh knights](assets/mika-ssh-knights.gif)

Pada Wireshark, gunakan filter berikut:

```wireshark
tcp.port == 22 && ip.addr == 10.64.1.3 && ip.addr == 10.64.3.2
```

| Paket | Nomor frame | Hasil pengamatan |
| --- | --- | --- |
| Protocol Version Exchange | 4 (Mika), 6 (Knights) | Client dan server mengirim banner `SSH-2.0-OpenSSH_10.2`. |
| Key Exchange Init / pertukaran kunci | 9, 11, 12, 13 | Frame 9 dan 11 berisi Key Exchange Init dari Mika dan Knights. Frame 12 berisi PQ/T Hybrid Key Exchange Init dan frame 13 berisi balasannya, menggunakan algoritma `mlkem768x25519-sha256` dengan host key `ssh-ed25519`. |
| New Keys | 13 (Knights), 16 (Mika) | Kedua arah mulai menggunakan kunci sesi dengan enkripsi `chacha20-poly1305@openssh.com`. Frame tersebut juga memuat Encrypted packet setelah New Keys. |

![ssh version exchange](assets/ssh-version-exchange.png)
![ssh key exchange](assets/ssh-key-exchange.png)

SSH mengenkripsi data autentikasi dan isi sesi setelah pertukaran kunci, sehingga tidak terbaca sebagai teks terbuka seperti Telnet. Pada autentikasi public key, client membuktikan kepemilikan kunci privat melalui tanda tangan digital; kunci privat tidak dikirim dan password akun tidak digunakan. Banner versi SSH pada awal koneksi masih dapat terlihat.

File capture: [`ssh_mika_knigths.pcapng`](captures/ssh_mika_knigths.pcapng).

14. Pada soal ini kita diminta untuk melakukan analisis file capture `wired_bruteforce.pcapng` untuk mengidentifikasi alamat IP penyerang, target IP beserta port yang diserang, password user `lain_admin`, serta web server software dan versinya.

*Langkah Penyelesaian*

Langkah pertama kita lihat lewat menu **Statistics -> Conversations**, disini kita akan mencari di TCP untuk melihat IP penyerang, target IP, dan port nya. Klik dua kali kolom 'Bytes' untuk mengurutkan data dari angka yang paling besar ke paling kecil dan melihat adanya komunikasi dua IP dengan jumlah paket yang sangat timpang dan angkanya jauh di atas rata-rata trafik lain, itu adalah indikasi kuat aliran serangan.

![IP_Port](assets/TCP_IP_Port.png)

Selanjutnya, untuk mencari password user `lain_admin`, web server software dan versinya. Karena kita sudah tau nama akunnya maka, selanjutnya kita menfilter dengan `frame contains lain_admin`. Lalu kita klik kanan, **follow TCP stream**. Kita akan melihat password akun dan web server software beserta versinya.

![Validasi_Soal-14](assets/Validasi_Soal-14.png)

15. Pada soal ini kita diminta untuk melakukan analisis file capture `wired_usb_hid.pcap` untuk mengidentifikasi Vendor ID dan Product ID perangkat USB dari deskriptor USB, alamat nomor device USB, serta pesan rahasia yang berhasil dicuri dari keystroke.

*Langkah Penyelesaian*

Mulai dengan mencari Vendor ID & Product ID, filter packet dengan `usb.bDescriptorType==1` untuk mencari informasi identitas utama perangkat lalu cari dengan info `"GET DESCRIPTOR Response DEVICE"`. Terdapat Device Descriptor yang berisi ID Vendor dan Product.

![DeviceDescriptor](assets/DEVICE_DESCRIPTOR.png)

Selanjutnya, aku buka menu **Statistics -> Conversations** dan di bagian USB untuk melihat alamat device USB. Disini Address A hanya 2 yaitu host dan `2.7.1`, dari sini kita tau bahwa `2.7.1` adalah Alamatnya. Namun, alamat USB biasanya Bus.Device.Endpoint maka dari itu nomor Device USB ada 7.

![Statistics->Conversations](assets/USB_Conversations.png)

Untuk mendapatkan pesan rahasia, dilakukan filter dengan `usb.capdata`. Disini kita bisa lihat keystroke di `Leftover Capture Data`. Lalu, kita baca `Byte 0` (untuk modifier keys) dan `Byte 2` (untuk tombol utama yang sedang dipegang) untuk mencari pesan rahasianya.

![LeftoverCaptureData](assets/Secret_code.png).

*Berikut adalah bagaimana kami menerjemahkan Byte nya:*
![Byte Code](assets/Byte_code.jpeg)

*Berikut adalah validasi temuan kami:*
![Validasi_Soal-14](assets/Validasi_Soal-15.png)

16. Pada soal ini kita diminta untuk melakukan analisis lalu lintas FTP untuk mengidentifikasi alamat IP server FTP penyerang, banner software FTP yang digunakan, kredensial login penyerang, serta ukuran (size in bytes) dari file malware knights_payload.exe yang diunduh.

*Langkah Penyelesaian*

Pertama, kita filterkan dengan `ftp.response.code==220`. Disini kita memakai kode `220` karena kode ini digunakan untuk mengundang klien untuk mengirimkan kredensial otentikasi (nama pengguna dan kata sandi). 
Kita menemukan Packet dengan info `220 Welcome to Wired FTP Server (vsftpd 3.0.5)`. Source pada packet tersebut adalah alamat IP server FTP penyerang dan info `(vsftpd 3.0.5)` adalah banner software FTP. 

![ftp.response.code==220](assets/Filter220.png)

Selanjutnya, kita bisa klik kanan dan **follow TCP stream**, disini kita akan terjawab kredensial login penyerang, serta ukuran (size in bytes) dari file malware.

![Validasi Pocket & Follow TCP Stream](assets/Validasi_Soal-16.png)

17. Menganalisis file capture `wired_http_c2.pcap` untuk mengidentifikasi nama domain (Host) tempat malware diunduh, alamat IP server penyerang, nama file executable malware yang diunduh, serta kode status HTTP yang dikembalikan.

*Langkah Penyelesaian*

Dimulai dengan mengfilter packet dengan `http.request.method=="GET"` karena command “GET” biasanya digunakan untuk meminta, menarik, atau mengambil data dari sebuah server. Setelah itu, kita akan mencari packet yang mencurigakan di kolom infonya. Disini kita akan melihat file `.exe` yang berbeda dengan permintaan `style.css`, maka file `.exe` tersebut mencurigakan. Disini kita lihat di kolom **Destinations** pada Packet tersebut bahwa itu adalah alamat IP penyerang.

![GET](assets/GET.png)

Lalu dilanjutkan dengan mengklik kanan dan **follow HTTP stream** pada packet tersebut yang akan menunjukan nama domain Host, nama filename `.exe`, dan kode status HTTP tersebut.

![Validasi_Soal-17](assets/Validasi_Soal-17.png)

18. Menganalisis file capture `wired_smb_transfer.pcapng` untuk mengidentifikasi nama protokol jaringan yang dieksploitasi, IP pengirim dan penerima, folder tujuan penyimpanan malware pada sistem korban, serta nama file executable malware yang ditransfer.

*Langkah Penyelesaian*

Langkah pertama yaitu mengidentifikasi nama protokol jaringan yang dieksploitasi, protokol biasany ditulis menjadi `SMB` atau `SMB2`, untuk hal ini kami pertama-tama memfilter `smb` namun tidak ada packet tersebut dan ketika memfilter `smb2` maka akan keluar banyak packet protokol `SMB2`.

Selanjutnya, kami memfilter dengan `smb2.filename` untuk melihat file apa yang sedang ditulis oleh penyerang lalu lihat bagian info dan cari yang memiliki **Create Request File**. Di kolom **Source** packet tersebut terlihat IP penyerang, lalu kita akan melihat ke bagian **SMB2 (Server Message Block Protocol version 2)**, yang **Create Request**.

![smb2](assets/smb2.filename.png)

Di dalam tersebut terlihat Filename: `System32\wired_trojan_payload.exe`. `System32` adalah folder tujuan dan `wired_trojan_payload.exe` adalah filename malwarenya.

![Validasi_Soal-18](assets/Validasi_Soal-18.png)


19. Menganalisis file capture `wired_smtp_threat.pcap` pada stream TCP terkait, identifikasi alamat email korban yang ditargetkan, password korban yang diklaim bocor oleh penyerang, jenis malware yang diinfeksikan, batas waktu (dalam hari) yang diberikan, serta `MailClientID` yang tercantum pada pesan.

*Langkah Penyelesaian*

Karena kita sudah tau isinya ada `MailClientID` maka kita akan mengfilter packet dengan `frame contains "MailClientID"`.

![MailClientID](assets/MailClientID.png)

Selanjutnya kita klik kanan dan **follow TCP Stream**, disitu kita dapat melihat Email penyerang dan korban yang ditargetkan, pesan dr penyerang dan ancaman oleh penyerang.

![Validasi_Soal-19](assets/Validasi_Soal-19.png)

20. Mengidentifikasi versi protokol TLS yang dinegosiasikan, nama domain (SNI) yang diakses, alamat IP server HTTPS penyerang, User-Agent yang digunakan, serta HTTP request method dan path yang tersembunyi di dalam sesi dekripsi pada file capture `wired_tls_decrypt.pcapng` bersama `keyslogfile.txt`.

Langkah Penyelesaian

Pertama-tama kita akan mencari **Client Hello** atau bisa dengan filter `tls.handshake.type == 1` dan dibagian **Destinations** terdapat IP server penyerang dan TLS protocol apa. Selanjutnya, untuk mencari SNI, klik dua kali pada packet **Client Hello** lalu ke panel detail **Handshake Protocol : Client Hello -> Extensions : Server_name -> Server Name Indication Extention**. Akan terdapat nama domai (SNI).

![TampakAwal](assets/TampakAwal.png)

Kami diberi keylogs untuk melihat `User-Agent`, HTTP request method dan path yang tersembunyi. Klik menu **Edit**, lalu pilih **Preferences**. Klik dropdown pada **Protocols**, lalu cari dan pencet **TSL**. Cari kolom yang bernama **(Pre)-Master-Secret log filename** lalu browse file keylogs yang sudah dikasih, pencet **OK**. 

![TSL](assets/TSL.png)

Maka tampilan akan berbeda dan akan langsung terlihat `User-Agent`, method, dan path pada panel bawah.

![TampakAkhir](assets/TampakAkhir.png)

*Berikut adalah validasi temuan kami:*

![Validasi_Soal-20](assets/Validasi_Soal-20.png)

