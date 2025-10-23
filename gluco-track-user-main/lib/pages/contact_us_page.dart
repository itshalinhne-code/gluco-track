import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/social_media_model.dart';
import '../services/social_media_servcie.dart';
import '../utilities/api_content.dart';
import '../utilities/image_constants.dart';
import '../widget/app_bar_widget.dart';
import '../widget/image_box_widget.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IAppBar.commonAppBar(title: "Liên hệ chúng tôi"),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return ListView(
      controller: scrollController,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 2.5,
          child: Image.asset(ImageConstants.contactImage),
        ),
        const Text(
          "Liên hệ chúng tôi",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          "Địa chỉ: 123 Đường Cầu Giấy, \nQuận Cầu Giấy, Hà Nội \n Gọi cho chúng tôi \n 0966 969 666",
          textAlign: TextAlign.center,
          style: const TextStyle(
            letterSpacing: 1,
            fontSize: 15,
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              const Icon(Icons.home),
              const SizedBox(width: 10),
              Flexible(
                  child: Text(
                "Địa chỉ: 123 Đường Cầu Giấy, Quận Cầu Giấy, Hà Nội",
                textAlign: TextAlign.start,
                style: const TextStyle(
                  letterSpacing: 1,
                  fontSize: 15,
                ),
              ))
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              iconSize: 20,
              icon: const Icon(FontAwesomeIcons.phone),
              onPressed: () async {
                if ("0966 969 666" != "") {
                  await launchUrl(Uri.parse("tel:0966 969 666"));
                }
              },
            ),
            // const  SizedBox(width: 10),
            Flexible(
                child: Text(
              "Điện thoại: 0966 969 666",
              textAlign: TextAlign.start,
              style: const TextStyle(letterSpacing: 1, fontSize: 15),
            ))
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(FontAwesomeIcons.whatsapp),
              onPressed: () async {
                if ("0966 969 666" != "") {
                  final url = "https://wa.me/0966 969 666?text=Hello"; //remember country code
                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                }
              },
            ),
            // const  SizedBox(width: 10),
            Flexible(
                child: Text(
              "Whatsapp: 0966 969 666",
              textAlign: TextAlign.start,
              style: const TextStyle(letterSpacing: 1, fontSize: 15),
            ))
          ],
        ),
        const Divider(),
        FutureBuilder(
            future: SocialMediaService.getData(),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? ListView.builder(
                      controller: scrollController,
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        SocialMediaModel socialMedialModel = snapshot.data![index];
                        return Card(
                          elevation: .1,
                          child: ListTile(
                            onTap: () async {
                              if (socialMedialModel.url != null) {
                                try {
                                  await launchUrl(Uri.parse(socialMedialModel.url!),
                                      mode: LaunchMode.externalApplication);
                                } catch (e) {
                                  if (kDebugMode) {
                                    print(e);
                                  }
                                }
                              }
                            },
                            contentPadding: const EdgeInsets.all(8),
                            leading: socialMedialModel.image == null
                                ? const Icon(Icons.image)
                                : SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: ImageBoxFillWidget(
                                        imageUrl:
                                            "${ApiContents.imageUrl}/${socialMedialModel.image}")),
                            title: Text(socialMedialModel.title ?? "",
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                          ),
                        );
                      })
                  : Container();
            })
      ],
    );
  }
}
