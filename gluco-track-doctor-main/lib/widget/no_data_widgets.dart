import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../utilities/image_constants.dart';

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 250,
            width: 250,
            child: SvgPicture.asset(ImageConstants.noDataImage, semanticsLabel: 'Logo'),
          ),
          const SizedBox(height: 20),
          Text("Không tìm thấy dữ liệu!",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              )),
        ],
      ),
    );
  }
}
