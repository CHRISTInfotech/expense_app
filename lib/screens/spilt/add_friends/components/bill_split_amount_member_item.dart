import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BillSplitAmountMemberListItem extends StatelessWidget {
  final String name, profileImage, phoneNumber;
  final bool isSelected;
  final TextEditingController billeachAmount;

  BillSplitAmountMemberListItem({
    Key? key,
    required this.name,
    required this.profileImage,
    required this.phoneNumber,
    this.isSelected = false, required this.billeachAmount,
  }) : super(key: key);

  // final TextEditingController billeachAmount = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                backgroundImage: CachedNetworkImageProvider(profileImage),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    phoneNumber,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isSelected) ...[
            Container(
              height: 50,
              width: 70,
              child:  TextField(
                controller: billeachAmount,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  prefixText: "₹",
                  border: InputBorder.none,
                  hintText: "Enter Bill Amount here...",
                ),
              ),
            ),
          ] else ...[
            //
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFC8C8C8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  width: 1,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
