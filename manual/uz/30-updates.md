# Yangilanishlar

Spherie va paketlaringiz Spherie menyusidagi _Update > Omarchy_ (`Super + Space`) orqali yangilab turiladi.

Spherie'ning o'zi [Spherie paketlar repozitoriyasi](https://github.com/omacom-io/omarchy-pkgs)dan oddiy pacman paketlari sifatida o'rnatiladi, shuning uchun yangilanish [eng so'nggi Spherie relizini](https://github.com/omacom/omarchy/releases) o'rnatadi, tizimingizni eng so'nggi versiya bilan sinxron holatga keltirish uchun barcha kutilayotgan migratsiyalarni ishga tushiradi va [Spherie Arch Mirror](https://github.com/omacom-io/omarchy-mirror) hamda [AUR](https://aur.archlinux.org/)dan (agar biror AUR paketlarini o'rnatgan bo'lsangiz) barcha tizim paketlarini yangilaydi.

Yangi relizlar chiqqanda, soatingizning o'ng tomonida doiraviy strelka belgisi paydo bo'ladi. Uni bosing va yangilash jarayoni boshlanadi.

![update-available](images/update-available.webp)

### To'rtta kanal

Spherie to'rtta kanal bo'ylab yangilanadi: stable, RC, edge va dev. Yangi o'rnatishlar stable kanalidan boshlanadi, u [rasmiy relizlarni](https://github.com/omacom/omarchy/releases/), shuningdek eng so'nggisidan bir oy orqada yuradigan [barqaror Spherie Arch mirror](https://github.com/omacom-io/omarchy-mirror)ni kuzatib boradi, shu tariqa biz konfiguratsiya o'zgarishlarini talab qiladigan yangi nomuvofiqliklarni odamlar uchun muammo tug'dirishidan oldin aniqlay olamiz.

Ammo agar siz o'sha ehtimoliy muammolarni aniqlashga yordam bermoqchi bo'lsangiz, edge kanalida ishlashingiz mumkin. Bu Spherie paketlaringizni eng so'nggi development build'larni kuzatib boradigan qilib qo'yadi va Arch paketlari paydo bo'lishi bilanoq eng so'nggilariga yangilash imkonini beradi. Buni faqat Linux bilan tajribangiz bo'lsa va muammoga uchragan tizimni qanday tiklashni bilsangizgina qilishingiz kerak.

Har qanday yangi yirik relizdan oldin, yakuniy tekshiruvni RC kanali yordamida amalga oshiramiz. Agar yakuniy sayqal berishda yordam berishga qiziqsangiz, Discord'dagi #omarchy-release-candidates kanaliga keling.

Nihoyat, dev kanali ham bor, u Spherie'ni to'g'ridan-to'g'ri `~/omarchy`dagi manba kodining git checkout'iga, edge paketlari bilan birgalikda bog'laydi. Bu kanaldan faqat tajribali Linux foydalanuvchisi bo'lsangiz, to'g'ridan-to'g'ri Spherie ustida ishlayotgan bo'lsangiz va buzilishlarga chidashga tayyor bo'lsangizgina foydalanishingiz kerak.

Kanallar o'rtasida Spherie menyusidagi _Update > Channel_ orqali (yoki terminalda `omarchy-channel-set`) almashishingiz mumkin.

### Yadrolarni almashtirish

Spherie o'zining `linux-omarchy` yadrosini yuklaydi, ammo uning yonida boshqalarini ham o'rnatib qo'yishingiz mumkin, masalan standart Arch `linux` yadrosi yoki siz sinayotgan eksperimental build. Bittadan ortiq yadro bo'lganda, Spherie menyusidagi _Update > Kernel_ ularni ro'yxat qiladi va sukut bo'yicha yuklanadiganining yoniga belgi qo'yadi. Boshqasini tanlang, parolingizni bir marta kiriting va u keyingi qayta yuklashdan keyin yuklanadi. Boshqa yadrolar yuklash menyusida qoladi, shuning uchun yangi sukut bo'yicha variant sizga muammo tug'dirsa, birini qo'lda tanlashingiz ham mumkin. Terminalda, joriy sukut bo'yicha variantni ko'rish uchun `omarchy-kernel`, nima o'rnatilganini ko'rish uchun `omarchy-kernel list` va almashish uchun `omarchy-kernel set <kernel>`.

### Firmware yangilanishlari

Eskirib qoladigan narsa faqat paketlaringiz emas. Ko'plab noutbuklar va periferiya qurilmalari BIOS, SSD va dok firmware'ini Linux Vendor Firmware Service orqali yetkazib beradi va Spherie menyusidagi _Update > Firmware_ qurilmangizda kutilayotgan narsalarning hammasini olib kelib o'rnatadi. U birinchi marta ishga tushirganingizda `fwupd`ni o'rnatadi. Ko'plab firmware'lar faqat qayta yuklash vaqtida yozilishi mumkin, shuning uchun sizdan qayta yuklash so'ralsa, hayron bo'lmang.

BIOS'ning o'zida biror sozlamani o'zgartirishingiz kerak bo'lganda, tizim menyusida (`Super + Escape`) `Alt`ni bosib turing va _Reboot_ _Reboot to BIOS_ga aylanadi, u yuklash paytida kerakli tugmani bosishga ulgurishga harakat qilmasdan to'g'ridan-to'g'ri firmware sozlamalariga qayta yuklanadi. Terminaldan bu `omarchy system firmware`.

### To'g'ridan-to'g'ri pacman/yay yangilanishlari haqida ogohlantirish

Agar Arch bilan allaqachon tanish bo'lsangiz, shunchaki `pacman -Syu` yoki `yay -Syu`ni o'zingiz ishga tushirishga vasvasaga tushishingiz mumkin, ammo agar shunday qilsangiz, Spherie yangi paketlar bilan birgalikda ishga tushiradigan snapshot, migratsiyalar va konfiguratsiya yangilanishlarini o'tkazib yuborasiz. Shuning uchun Spherie to'g'ridan-to'g'ri tizim yangilanishini aslida to'xtatadi va buning o'rniga sizni `omarchy update`ga yo'naltiradi. (Agar chindan ham nima qilayotganingizni bilsangiz, himoya bitta tranzaksiya uchun uni qanday chetlab o'tishni aytib beradi.)

### Muvaffaqiyatsiz yangilanishlarni orqaga qaytarish

Agar yangilanish qilganingizdan keyin biror muammoga duch kelsangiz, tizimingizni yangilanishdan oldin olingan snapshot holatiga qaytarishingiz mumkin. Shunchaki qayta yuklang va yuklash menyusidan yangilanishni boshlashingizdan oldingi snapshotni tanlang.

![bootloader](images/bootloader.webp)

Agar qandaydir tarzda konfiguratsiya fayllaringiz buzilgan bo'lsa, terminalda `omarchy reinstall` orqali Spherie'ni qayta o'rnatishni ham amalga oshirishingiz mumkin. Bu barcha standart Spherie paketlarini qayta o'rnatadi, sizni stable kanaliga o'tkazadi va juda yangi bo'lgan barcha paketlarni pasaytiradi hamda barcha konfiguratsiya fayllarini tiklaydi. E'tibor bering, buni qilishda Spherie standartlariga kiritgan barcha foydalanuvchi konfiguratsiya o'zgarishlaringiz ustidan yozib yuboriladi!
