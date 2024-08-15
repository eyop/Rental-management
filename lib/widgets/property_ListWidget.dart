import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rental_management/models/property_model.dart';
import 'package:rental_management/screens/property_details.dart';
import 'package:rental_management/utils/method_utils.dart';

class PropertyListWidget extends StatelessWidget {
  final List<PropertyModel> propertyRentList;

  const PropertyListWidget({super.key, required this.propertyRentList});

  @override
  Widget build(BuildContext context) {
    var dateFormat = DateFormat("dd, MM, yyyy");

    return propertyRentList.isEmpty
        ? const Center(
            child: Text(
              "No data found!!",
              style: TextStyle(fontSize: 20),
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            itemCount: propertyRentList.length,
            itemBuilder: (BuildContext context, int index) {
              var rentModel = propertyRentList[index];
              final postedDate = getDateFromDateTimeInSpecificFormat(
                  dateFormat, rentModel.updatedAt ?? "dd MM, yyyy");
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PropertyDetails(
                        rentModel: rentModel,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin:
                      const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
                  elevation: 5,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  child: SizedBox(
                    height: 180, // Ensure enough height for all elements
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            bottomLeft: Radius.circular(12.0),
                          ),
                          child: SizedBox(
                            height: 180,
                            width: 130,
                            child: rentModel.images == null ||
                                    rentModel.images!.isEmpty ||
                                    rentModel.images![0].isEmpty
                                ? placeHolderAssetWidget()
                                : fetchImageWithPlaceHolder(
                                    rentModel.images![0]),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "ETB ${rentModel.price}",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Posted on  : $postedDate",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    fontFamily:
                                        GoogleFonts.openSans().fontFamily,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Type : ${rentModel.propertyType}" ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    fontFamily:
                                        GoogleFonts.openSans().fontFamily,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Location : ${rentModel.city}" ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    fontFamily:
                                        GoogleFonts.openSans().fontFamily,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Flexible(
                                  child: Text(
                                    "Info : ${rentModel.description}" ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w600,
                                      fontFamily:
                                          GoogleFonts.openSans().fontFamily,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Icon(Icons.phone,
                                        color: Theme.of(context).primaryColor),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Text(rentModel.contact),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 20),
          );
  }
}

// Utility method to fetch image
Widget fetchImageWithPlaceHolder(String imageUrl) => imageUrl.isNotEmpty
    ? Image.network(
        imageUrl,
        fit: BoxFit.fill,
      )
    : placeholderAssetWidget();

// Placeholder widget for images
Widget placeholderAssetWidget() => const Icon(
      Icons.house_outlined,
      size: 120.0,
      color: Colors.black26,
    );
