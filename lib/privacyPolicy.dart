import 'package:flutter/material.dart';

class PrivacyPolicy extends StatefulWidget {
  static const String routeName = '/privacyPolicy';

  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white, // Assuming you want a white background
      appBar: AppBar(
        backgroundColor: Colors.white, // Assuming you want a white background
        automaticallyImplyLeading: false,
        leading: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.chevron_left_rounded,
            color: Colors.grey,
            size: 32,
          ),
        ),
        title: Text(
          'Gizlilik Politikası', // Assuming you want a static title
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: 22,
            letterSpacing: 0,
            color: Colors.black,
            // Assuming you want black text
          ),
        ),
        actions: [], // Assuming you want no actions
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Verilerinizi nasıl kullanıyoruz?',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 25,
                        letterSpacing: 0,
                        // Assuming you want black text
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Panic Link uygulaması olarak, kullanıcılarımızın gizliliğine ve kişisel verilerinin korunmasına büyük önem veriyoruz. Bu gizlilik politikası, Panic Link uygulamasını kullanırken kişisel bilgilerinizin nasıl toplandığı, kullanıldığı, saklandığı ve korunduğu konusunda sizleri bilgilendirmek amacıyla hazırlanmıştırPanic Link uygulaması, kullanıcılarımızın acil durumlarda hızlıca yardım çağrısı göndermesini ve yakınlarıyla iletişim kurmasını sağlamak için tasarlanmıştır. '
                      'Bu süreçte, adınız, soyadınız, telefon numaranız ve e-posta adresiniz gibi kişisel bilgilerinizi topluyoruz. Ayrıca, giyilebilir cihazlarınızın adı, seri numarası, modeli, anlık konum bilgileri ve geçmiş konum kayıtları gibi cihaz bilgileriniz ile sıcaklık, nem gibi sensör verilerinizi de işliyoruz.Topladığımız bu bilgileri, Panic Link uygulamasının işlevselliğini sağlamak, kullanıcı deneyimini iyileştirmek ve size daha güvenli bir hizmet sunmak için kullanıyoruz. Bu bilgiler sayesinde, cihazınızın anlık konumunu harita üzerinde görüntüleyebilir, geçmiş alarm çağrılarınızı tarih, saat ve konum bilgileri ile birlikte listeleyebilir ve size gerçek zamanlı'
                      'durum bildirimleri gönderebiliriz.Kişisel bilgileriniz, yasal zorunluluklar dışında üçüncü taraflarla paylaşılmaz, satılmaz veya kiralanmaz. Bilgilerinizi güvenli sunucularımızda saklıyor ve yetkisiz erişim, kayıp veya değişikliklere karşı endüstri standartlarında güvenlik önlemleri alıyoruz.Panic Link uygulaması,'
                      ' kullanıcılarımızın gizlilik haklarına saygı duyar. Kişisel verilerinize erişim talep edebilir, yanlış veya eksik bilgilerin düzeltilmesini isteyebilir ve yasal gereksinimlere tabi olarak verilerinizin silinmesini talep edebilirsiniz. Ayrıca, uygulamanın kullanımını analiz etmek ve size kişiselleştirilmiş içerik sunmak amacıyla çerezler ve benzeri izleme teknolojileri kullanmaktayız.Bu gizlilik politikası, zaman zaman güncellenebilir. Politika değişiklikleri hakkında sizleri uygulama üzerinden bilgilendireceğiz. Politikamız hakkında daha fazla bilgi almak veya sorularınızı iletmek için bizimle iletişime geçebilirsiniz.Panic Link olarak, kişisel verilerinizin korunması ve gizliliğinizin sağlanması için çalışmalarımıza devam ediyoruz. Güveniniz için teşekkür ederiz. ',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 14,
                        letterSpacing: 0,
                        color: Colors.black54, // Assuming you want black text

                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
