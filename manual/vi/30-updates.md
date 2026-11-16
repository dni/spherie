# Cập nhật

Spherie và các gói của bạn được giữ ở trạng thái mới nhất thông qua _Update > Omarchy_ trong menu Spherie (`Super + Space`).

Bản thân Spherie được cài đặt dưới dạng các gói pacman thông thường từ [Spherie Package Repository](https://github.com/omacom-io/omarchy-pkgs), vì vậy một lần cập nhật sẽ cài đặt [bản phát hành Spherie mới nhất](https://github.com/omacom/omarchy/releases), chạy mọi quá trình di chuyển còn đang chờ để đồng bộ hệ thống của bạn với bản mới nhất, và cập nhật tất cả các gói hệ thống từ [Spherie Arch Mirror](https://github.com/omacom-io/omarchy-mirror) và [AUR](https://aur.archlinux.org/) (nếu bạn đã cài đặt bất kỳ gói AUR nào).

Khi có các bản phát hành mới, một biểu tượng mũi tên vòng tròn sẽ xuất hiện ở bên phải đồng hồ của bạn. Nhấp vào biểu tượng đó và quá trình cập nhật sẽ bắt đầu.

![update-available](images/update-available.webp)

### Bốn kênh

Spherie được cập nhật qua bốn kênh: stable, RC, edge và dev. Các bản cài đặt mới bắt đầu trên kênh stable, kênh này theo dõi [các bản phát hành chính thức](https://github.com/omacom/omarchy/releases/), cũng như [stable Spherie Arch mirror](https://github.com/omacom-io/omarchy-mirror) chạy chậm hơn một tháng so với bản mới nhất, để chúng ta có thể phát hiện mọi sự không tương thích mới đòi hỏi phải thay đổi cấu hình trước khi chúng gây ra vấn đề cho mọi người.

Nhưng nếu bạn muốn giúp phát hiện những vấn đề tiềm ẩn đó, bạn có thể chạy trên kênh edge. Kênh đó sẽ giữ cho các gói Spherie của bạn theo dõi các bản dựng phát triển mới nhất, và cho phép bạn cập nhật lên các gói Arch mới nhất ngay khi chúng có sẵn. Bạn chỉ nên làm điều này nếu bạn đã có kinh nghiệm với Linux và biết cách khôi phục một hệ thống gặp sự cố.

Trước bất kỳ bản phát hành chính mới nào, chúng tôi sẽ tiến hành kiểm tra xác thực cuối cùng bằng kênh RC. Nếu bạn quan tâm đến việc giúp hoàn thiện những bước cuối cùng, hãy ghé qua #omarchy-release-candidates trên Discord.

Cuối cùng, có kênh dev, kênh này liên kết Spherie trực tiếp tới một bản checkout git của mã nguồn trong `~/omarchy`, kết hợp với các gói edge. Bạn chỉ nên sử dụng kênh này nếu bạn là người dùng Linux có kinh nghiệm, đang làm việc trực tiếp trên Spherie, và sẵn sàng chấp nhận khả năng hỏng hóc.

Bạn có thể chuyển đổi giữa các kênh bằng _Update > Channel_ trong menu Spherie (hoặc `omarchy-channel-set` trong terminal).

### Đổi kernel

Spherie khởi động bằng kernel `linux-omarchy` của riêng nó, nhưng bạn có thể cài các kernel khác bên cạnh nó, như kernel `linux` gốc của Arch hoặc một bản dựng thử nghiệm mà bạn đang kiểm tra. Khi có nhiều hơn một kernel, _Update > Kernel_ trong menu Spherie sẽ liệt kê chúng với một dấu chọn bên cạnh kernel được khởi động mặc định. Chọn một kernel khác, nhập mật khẩu của bạn một lần, và nó sẽ khởi động sau lần khởi động lại tiếp theo. Các kernel còn lại vẫn nằm trong menu khởi động, vì vậy bạn vẫn có thể tự tay chọn một kernel nếu kernel mặc định mới gây rắc rối cho bạn. Trong terminal, dùng `omarchy-kernel` để xem kernel mặc định hiện tại, `omarchy-kernel list` để xem những gì đã cài đặt, và `omarchy-kernel set <kernel>` để chuyển đổi.

### Cập nhật firmware

Các gói của bạn không phải là thứ duy nhất trở nên lỗi thời. Nhiều laptop và thiết bị ngoại vi cung cấp firmware cho BIOS, SSD và dock thông qua Linux Vendor Firmware Service, và _Update > Firmware_ trong menu Spherie sẽ tải về và cài đặt bất cứ thứ gì phần cứng của bạn đang chờ. Nó sẽ cài đặt `fwupd` trong lần đầu tiên bạn chạy. Rất nhiều firmware chỉ có thể được ghi trong lúc khởi động lại, vì vậy đừng ngạc nhiên khi bạn được yêu cầu khởi động lại.

Khi bạn cần thay đổi một thiết lập trong chính BIOS, hãy giữ `Alt` trong menu hệ thống (`Super + Escape`) và _Reboot_ sẽ biến thành _Reboot to BIOS_, mục này sẽ khởi động lại thẳng vào phần thiết lập firmware mà không cần phải canh đúng phím khi khởi động. Trong terminal, dùng `omarchy system firmware`.

### Cảnh báo về việc cập nhật trực tiếp bằng pacman/yay

Nếu bạn đã quen với Arch, bạn có thể bị cám dỗ chỉ chạy `pacman -Syu` hoặc `yay -Syu` tự mình, nhưng nếu bạn làm vậy, bạn sẽ bỏ lỡ snapshot, các quá trình di chuyển, và các bản cập nhật cấu hình mà Spherie chạy cùng với các gói mới. Đó là lý do Spherie thực sự sẽ chặn một lần nâng cấp hệ thống trực tiếp và hướng bạn tới `omarchy update` thay thế. (Nếu bạn thực sự biết mình đang làm gì, cơ chế bảo vệ sẽ cho bạn biết cách bỏ qua nó cho một giao dịch duy nhất.)

### Hoàn tác các bản cập nhật lỗi

Nếu bạn từng gặp sự cố sau khi thực hiện cập nhật, bạn có thể hoàn tác hệ thống của mình về snapshot được chụp trước lần cập nhật. Chỉ cần khởi động lại và chọn snapshot trong menu nạp khởi động từ trước khi bạn bắt đầu cập nhật.

![bootloader](images/bootloader.webp)

Nếu bằng cách nào đó các tệp cấu hình của bạn đã bị hỏng, bạn cũng có thể thực hiện cài đặt lại Spherie bằng `omarchy reinstall` trong terminal. Thao tác này sẽ cài đặt lại tất cả các gói Spherie mặc định, đưa bạn về stable và hạ cấp bất kỳ gói nào quá mới, đồng thời đặt lại tất cả các tệp cấu hình. Lưu ý rằng mọi thay đổi cấu hình người dùng của bạn đối với các mặc định của Spherie sẽ bị ghi đè khi làm điều này!
