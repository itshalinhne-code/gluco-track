import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_bar_code/qr/src/qr_code.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:userapp/helpers/route_helper.dart';
import 'package:userapp/model/clinic_model.dart';
import 'package:userapp/model/configuration_model.dart';
import 'package:userapp/pages/patient_file_page.dart';
import 'package:userapp/services/clinic_service.dart';
import 'package:userapp/services/configuration_service.dart';
import 'package:userapp/services/patient_files_service.dart';
import 'package:userapp/utilities/image_constants.dart';
import '../controller/appointment_cancel_req_controller.dart';
import '../controller/prescription_controller.dart';
import '../helpers/date_time_helper.dart';
import '../model/appointment_cancellation_model.dart';
import '../model/appointment_model.dart';
import '../model/invoice_model.dart';
import '../model/prescription_model.dart';
import '../services/appointment_service.dart';
import '../services/appointment_cancellation_service.dart';
import '../services/appointment_checkin_service.dart';
import '../services/doctor_service.dart';
import '../services/invoice_service.dart';
import '../widget/app_bar_widget.dart';
import '../widget/loading_Indicator_widget.dart';
import 'package:star_rating/star_rating.dart';
import '../helpers/theme_helper.dart';
import '../utilities/api_content.dart';
import '../utilities/colors_constant.dart';
import '../widget/button_widget.dart';
import '../widget/image_box_widget.dart';
import '../widget/toast_message.dart';
import 'package:get/get.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final String? appId;
  const AppointmentDetailsPage({super.key,this.appId});

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  bool _isLoading = false;
  AppointmentModel? appointmentModel;
  InvoiceModel? invoiceModel;

  final AppointmentCancellationController _appointmentCancellationController = AppointmentCancellationController();
  final PrescriptionController _prescriptionController = PrescriptionController();
  List<ConfigurationModel> listConfigModel=[];
  final ScrollController _scrollController = ScrollController();
  TextEditingController textEditingController = TextEditingController();
  double _rating = 4;
  int? _queueNumber;
  bool _isLoadingQueue = false;
  String? clinicLat;
  String? clinicLng;
  String? email;
  String? phone;
  String? whatsapp;
  String? ambulancePhone;
  bool patientFileAvailable=false;
  ClinicModel? clinicModel;
  @override
  void initState() {
    // TODO: implement initState
    getAndSetData();
    _appointmentCancellationController.getData(
        appointmentId: widget.appId ?? "-1");
    _prescriptionController.getData(appointmentId: widget.appId ?? "-1");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.bgColor,
      appBar: IAppBar.commonAppBar(title: "Lịch hẹn"),
      body: _isLoading || appointmentModel == null
          ? const ILoadingIndicatorWidget()
          : _buildBody(),
    );
  }

  _buildBody() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(5),
      children: [
        buildOpDetails(),
        const SizedBox(height: 3),
        Padding(padding: const EdgeInsets.only(bottom: 0),
          child: _buildPrescriptionListBox(),
        ),

      patientFileAvailable?  Padding(padding: const EdgeInsets.only(bottom: 10),
          child: _buildFileBox(),
        ):Container(),
        _buildClinicListTile(),
        const SizedBox(height: 3),
        _buildPaymentCard(),
        appointmentModel?.status=="Visited"||appointmentModel?.status=="Completed"? _buildReviewBox():Container(),
        const SizedBox(height: 3),
        appointmentModel?.status=="Visited"||appointmentModel?.status=="Completed"?Container(): _buildCancellationBox(),
        const SizedBox(height: 0),
         appointmentModel?.currentCancelReqStatus == null
            ? Container()
            : _buildCancellationReqListBox()
      ],
    );
  }

  void getAndSetData() async {
    setState(() {
      _isLoading = true;
    });
    final appointmentData = await AppointmentService.getDataById(
        appId: widget.appId);
    appointmentModel = appointmentData;

    final configRes=await ConfigurationService.getDataByGroupName("Basic");
    if(configRes!=null){
      for(var e in configRes){
        if(e.idName=="clinic_location_latitude"){
          clinicLat=e.value;
        }
        if(e.idName=="clinic_location_longitude"){
          clinicLng=e.value;
        }
        if(e.idName=="whatsapp"){
          whatsapp=e.value;
        }
        if(e.idName=="phone"){
          phone=e.value;
        }
        if(e.idName=="email"){
          email=e.value;
        }
        if(e.idName=="ambulance_phone"){
          ambulancePhone=e.value;
        }


      }
    }
    final patientFile=await PatientFilesService.getDataByPatientId(appointmentModel?.patientId.toString()??"");
    if(patientFile!=null&&patientFile.isNotEmpty){
      patientFileAvailable=true;
    }

    final invoiceData = await InvoiceService.getDataByAppId(
        appId: widget.appId);
    invoiceModel = invoiceData;
    getAndSetQueue();

    setState(() {
      _isLoading = false;
    });
    clinicModel=await ClinicService.getDataById(clinicId: appointmentModel?.clinicId.toString());
  }

  _buildProfileSection() {
    return Card(
      color: ColorResources.cardBgColor,
      elevation: .1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child:
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                    flex: 2,
                    child: Stack(
                      children: [
                        appointmentModel!.doctImage == null ||
                            appointmentModel!.doctImage == ""
                            ? const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 30,
                          child: Icon(Icons.person,
                            size: 40,),
                        )
                            : ClipOval(child:
                        SizedBox(
                          height: 80,
                          width: 80,
                          child: CircleAvatar(child: ImageBoxFillWidget(
                            imageUrl:
                            "${ApiContents.imageUrl}/${appointmentModel!
                                .doctImage}",
                            boxFit: BoxFit.fill,
                          )),
                        ),
                        ),

                        const Positioned(
                          top: 5,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.white, radius: 8,
                            child: CircleAvatar(backgroundColor: Colors.green,
                                radius: 6),),
                        )
                      ],
                    )),
                const SizedBox(width: 20),
                Flexible(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${appointmentModel?.doctFName ??
                            "--"} ${appointmentModel?.doctLName ?? "--"}",
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                          ),),
                        const SizedBox(height: 5),
                        Text(appointmentModel?.doctSpecialization ?? "",
                          style: const TextStyle(
                              color: ColorResources.secondaryFontColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12
                          ),),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            StarRating(
                              mainAxisAlignment: MainAxisAlignment.center,
                              length: 5,
                              color: appointmentModel?.averageRating == 0
                                  ? Colors.grey
                                  : Colors.amber,
                              rating: appointmentModel?.averageRating ?? 0,
                              between: 5,
                              starSize: 15,
                              onRaitingTap: (rating) {},
                            ),
                            const SizedBox(width: 10),
                            Text("${appointmentModel?.averageRating ??
                                0} (${appointmentModel?.numberOfReview ??
                                0} đánh giá)",
                              style: const TextStyle(
                                  color: ColorResources.secondaryFontColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12
                              ),)
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                                Icons.person, color: ColorResources.iconColor,
                                size: 15),
                            const SizedBox(width: 5),
                            Text("${appointmentModel?.totalAppointmentDone ??
                                0} Appointments Done",
                              style: const TextStyle(
                                  color: ColorResources.secondaryFontColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12
                              ),)
                          ],
                        )
                      ],))
              ],
            ),
            const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }

  buildOpDetails() {
    return Card(
      color: ColorResources.cardBgColor,
      elevation: .1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            const SizedBox(height: 10),
            appointmentModel?.type != "OPD"
                || appointmentModel?.status != "Confirmed"
                ? Container() :
            _queueNumber == null ?
            GestureDetector(
              onTap: () {
                openBoxToCheckIn();
              },
              child: Card(
                color: Colors.green,
                elevation: .1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Check-In",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.login_outlined,
                        color: Colors.white,
                      )

                    ],
                  ),
                ),
              ),
            )

                : Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _isLoadingQueue
                  ? const ILoadingIndicatorWidget()
                  : GestureDetector(
                onTap: () {
                  getAndSetQueue();
                },
                child: Card(
                  color: Colors.green,
                  elevation: .1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Số hàng đợi - ${_queueNumber.toString()}",
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.refresh,
                          color: Colors.white,
                        )

                      ],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Lịch hẹn #${widget.appId ?? "--"}",
                  style: const TextStyle(
                      color: ColorResources.secondaryFontColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600
                  ),),
                const SizedBox(width: 5),
                Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: appointmentModel!.status ==
                            "Pending"
                            ? _statusIndicator(Colors.yellowAccent)
                            : appointmentModel!.status ==
                            "Rescheduled"
                            ? _statusIndicator(Colors.orangeAccent)
                            : appointmentModel!.status ==
                            "Rejected"
                            ? _statusIndicator(Colors.red)
                            : appointmentModel!.status ==
                            "Confirmed"
                            ? _statusIndicator(Colors.green)
                            : appointmentModel!.status ==
                            "Completed"
                            ? _statusIndicator(Colors.green)
                            : null),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                      child: Text(
                        appointmentModel!.status ?? "--",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "${appointmentModel!.pFName ?? "--"} ${appointmentModel!.pLName ??
                  "--"}",
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600
              ),),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appointmentModel!.type ?? "--",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                appointmentModel!.type == "Video hỗ trợ" ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(5.0)),
                    ),
                    onPressed: appointmentModel!.status=="Visited"||
                        appointmentModel!.status=="Completed"||
                         appointmentModel!.meetingLink==""||appointmentModel!.meetingLink==null?null:() async{
                      final url=appointmentModel!.meetingLink??"";
                      await launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication
                      );
                      //   Get.toNamed(RouteHelper.getBookingDetailsPageRoute());

                    },
                    child: const Center(
                        child: Text("Video hỗ trợ",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            )))) : Container()
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Ngày",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12
                        ),),
                      GestureDetector(
                        onTap: () {},
                        child: Card(
                            color: ColorResources.cardBgColor,
                            elevation: .1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: ListTile(
                              title: Text(DateTimeHelper.getDataFormat(
                                  appointmentModel?.date ?? ""),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13
                                  )
                              ),
                              trailing: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  color: Colors.black,
                                  child:
                                  const Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Icon(Icons.calendar_month,
                                      color: Colors.white,
                                      size: 15,),
                                  )),
                            )),
                      )
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Thời gian",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12
                        ),),
                      GestureDetector(
                        onTap: () {

                        },
                        child: Card(
                            color: ColorResources.cardBgColor,
                            elevation: .1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),

                            child: ListTile(
                              title: Text(DateTimeHelper.convertTo12HourFormat(
                                  appointmentModel?.timeSlot ?? ""),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13
                                ),),
                              trailing: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  color: Colors.black,
                                  child:
                                  const Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Icon(Icons.watch_later,
                                      size: 15,
                                      color: Colors.white,),
                                  )),
                            )),
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            SmallButtonsWidget(title: "Đặt lại lịch hẹn", onPressed: () {
              if(appointmentModel!.doctorId!=null){
                Get.toNamed(RouteHelper.getDoctorsDetailsPageRoute(doctId: appointmentModel!.doctorId!.toString()));
              }


              // _openBottomSheet();
            }),
            const SizedBox(height: 10),
          ],

        ),
      ),
    );
  }

  Widget _statusIndicator(color) {
    return CircleAvatar(radius: 4, backgroundColor: color);
  }

  _buildPaymentCard() {
    return GestureDetector(
      onTap: () {
        //download invoice
      },
      child: Card(
        color: ColorResources.cardBgColor,
        elevation: .1,
        // elevation: .1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          onTap: ()async{
            await launchUrl(Uri.parse(
                "${ApiContents.invoiceUrl}/${invoiceModel?.id}"),
            mode: LaunchMode.externalApplication
            );
          },
          title: Text(
            "Trạng thái thanh toán ${invoiceModel == null ? "--" : invoiceModel
                ?.paymentId.toString() ?? "--"}",
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14
            ),),
          trailing: Text(
            invoiceModel == null ? "--" : invoiceModel?.status ?? "--",
            style: const TextStyle(
                color: ColorResources.primaryColor,
                // fontWeight: FontWeight.w500,
                fontSize: 13
            ),),
          subtitle: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Tải hóa đơn",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                        fontSize: 14
                        ,
                      )),
                  SizedBox(width: 5),
                  Icon(Icons.download,
                      color: Colors.green,
                      size: 16)
                ],
              )

            ],
          ),
        ),
      ),
    );
  }


  _buildClinicListTile() {
    return   Card(
      elevation: .1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading:    clinicModel?.image==null|| clinicModel?.image==""?
        const SizedBox(
          height: 70,
          width: 70,
          child: Icon(Icons.image,
              size: 40),
        )
            :   SizedBox(
            height: 70,
            width: 70,
            child: CircleAvatar(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10), // Adjust the radius according to your preference
                child: ImageBoxFillWidget(
                  imageUrl: "${ApiContents.imageUrl}/${clinicModel?.image}",
                  boxFit: BoxFit.fill,
                ),
              ),
            )
        ),
        title: Text(
          clinicModel?.title??"",
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500
          ),
        ),
        subtitle: Column(
          children: [
            Text(
              clinicModel?.address??"",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400
              ),
            ),
            clinicModel==null?Container() :
            clinicModel?.longitude==null|| clinicModel?.latitude==null?Container():      Row(
              children: [
               Flexible(
                 child: Text("Làm hướng dẫn đến vị trí phòng khám",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500
                    ),),
               ),
                GestureDetector(
                  onTap: ()async{
                    final url="http://maps.google.com/maps?daddr=${clinicModel?.latitude},${clinicModel?.longitude}";
                    try{
                      await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                    }catch(e){
                      if (kDebugMode) {
                        print(e);
                      }
                    }
                  },
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: ColorResources.primaryColor,
                    child: Icon(FontAwesomeIcons.locationDot,
                        color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            )

          ],
        ),
      ),
    );
  }
  // _buildNavigationBox() {
  //   return ListTile(
  //     onTap: ()async{
  //
  //         final url="http://maps.google.com/maps?daddr=${clinicModel?.latitude},${clinicModel?.longitude}";
  //         try{
  //           await launchUrl(Uri.parse(url),
  //           mode: LaunchMode.externalApplication);
  //         }catch(e){
  //           if (kDebugMode) {
  //             print(e);
  //           }
  //         }
  //
  //     },
  //     leading: const Icon(Icons.map),
  //     trailing: const Icon(Icons.assistant_navigation,
  //         color: ColorResources.primaryColor
  //     ),
  //     title: const Text("Make direction to clinic location",
  //       style: TextStyle(
  //           fontSize: 14,
  //           fontWeight: FontWeight.w500
  //       ),),
  //   );
  // }

  _buildReviewBox() {
    return Padding(
      padding: const EdgeInsets.only(top:8.0),
      child: Card(
        color: ColorResources.cardBgColor,
        elevation: .1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          onTap: () {
            _openDialogBoxReview();
          },
          title: const Text("Đánh giá",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500
            ),),
          subtitle: const Text("Nhấn vào đây để đánh giá bác sĩ",
            style: TextStyle(
                fontSize: 13,
                color: ColorResources.secondaryFontColor,
                fontWeight: FontWeight.w400
            ),),
        ),
      ),
    );
  }


  _buildCancellationBox() {
    return Card(
      color: ColorResources.cardBgColor,
      elevation: .1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: ListTile(
        onTap: appointmentModel?.currentCancelReqStatus == null
            ? _openDialogBox
            :
        appointmentModel?.currentCancelReqStatus == "Initiated"
            ? _openDialogBoxDeleteReq
            :
        null,
        trailing: const Icon(Icons.arrow_right,
          color: ColorResources.btnColor,),
        title: const Text("Hủy lịch hẹn",
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500
          ),),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            appointmentModel?.currentCancelReqStatus == null ? const Text(
              "Nhấn vào đây để tạo yêu cầu hủy lịch hẹn",
              style: TextStyle(
                  color: ColorResources.secondaryFontColor,
                  fontSize: 13
              ),) :
            appointmentModel?.currentCancelReqStatus == "Initiated" ?
            const Text("Nhấn vào đây để xóa yêu cầu hủy lịch hẹn",
              style: TextStyle(
                  color: ColorResources.secondaryFontColor,
                  fontSize: 13
              ),)
                : Container(),
            appointmentModel?.currentCancelReqStatus == null
                ? Container()
                : Text(
              "Trạng thái hiện tại - ${appointmentModel?.currentCancelReqStatus ??
                  "--"}",
              style: const TextStyle(
                  color: ColorResources.secondaryFontColor,
                  fontSize: 13
              ),),

          ],
        ),
      ),
    );
  }

  _openDialogBoxReview() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                title: const Text(
                  "Đánh giá bác sĩ",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Đánh giá bác sĩ ${appointmentModel?.doctFName ??
                        "--"} ${appointmentModel?.doctLName ?? "--"}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 12)),
                    const SizedBox(height: 10),
                    StarRating(
                      mainAxisAlignment: MainAxisAlignment.center,
                      length: 5,
                      color: Colors.amber,
                      rating: _rating,
                      between: 5,
                      starSize: 30,
                      onRaitingTap: (rating) {
                        // print('Clicked rating: $rating / $starLength');
                        setState(() {
                          _rating = rating;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                      child: TextFormField(
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        validator: null,
                        controller: textEditingController,
                        decoration: ThemeHelper().textInputDecoration('Đánh giá'),
                      ),
                    )
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorResources.btnColorRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10), // Change this value to adjust the border radius
                        ),
                      ),
                      child: const Text("Hủy",
                          style:
                          TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400, fontSize: 12)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorResources.btnColorGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10), // Change this value to adjust the border radius
                        ),
                      ),
                      child: const Text(
                        "Gửi",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400, fontSize: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _handleToSubmitReview();
                        // _handleAppointmentCanReq();
                      }),
                  // usually buttons at the bottom of the dialog
                ],
              );
            }
        );
      },
    );
  }

  _openDialogBox() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text(
            "Hủy",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Bạn có chắc chắn muốn hủy lịch hẹn này không",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
              SizedBox(height: 10),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorResources.btnColorGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Change this value to adjust the border radius
                  ),
                ),
                child: const Text("Không",
                    style:
                    TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400, fontSize: 12)),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorResources.btnColorRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Change this value to adjust the border radius
                  ),
                ),
                child: const Text(
                  "Có",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400, fontSize: 12),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleAppointmentCanReq();
                }),
            // usually buttons at the bottom of the dialog
          ],
        );
      },
    );
  }

  _openDialogBoxDeleteReq() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text(
            "Xóa",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Bạn có chắc chắn muốn xóa yêu cầu hủy lịch hẹn này không",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
              SizedBox(height: 10),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorResources.btnColorRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Change this value to adjust the border radius
                  ),
                ),
                child: const Text("Không",
                    style:
                    TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400, fontSize: 12)),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorResources.btnColorGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Change this value to adjust the border radius
                  ),
                ),
                child: const Text(
                  "Có",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400, fontSize: 12),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleAppointmentDeleteReq();
                }),
            // usually buttons at the bottom of the dialog
          ],
        );
      },
    );
  }

  void _handleToSubmitReview() async {
    setState(() {
      _isLoading = true;
    });
    final res = await DoctorsService.addDoctorReView(
      appointmentId: appointmentModel?.id.toString() ?? "",
      description: textEditingController.text,
      doctorId: appointmentModel?.doctorId?.toString() ?? "",
      points: _rating.toString(),
    );
    if (res != null) {
      IToastMsg.showMessage("success");
      _appointmentCancellationController.getData(
          appointmentId: widget.appId ?? "-1");
      getAndSetData();
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _handleAppointmentCanReq() async {
    setState(() {
      _isLoading = true;
    });
    final res = await AppointmentCancellationService
        .addAppointmentCancelRequest(
        appointmentId: appointmentModel?.id.toString() ?? "",
        status: "Initiated");
    if (res != null) {
      IToastMsg.showMessage("success");
      _appointmentCancellationController.getData(
          appointmentId: widget.appId ?? "-1");
      getAndSetData();
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _handleAppointmentDeleteReq() async {
    setState(() {
      _isLoading = true;
    });
    final res = await AppointmentCancellationService.deleteReq(
        appointmentId: appointmentModel?.id.toString() ?? "");
    getAndSetData();
    _appointmentCancellationController.getData(
        appointmentId: widget.appId ?? "-1");
    if (res != null) {
      IToastMsg.showMessage("success");
      getAndSetData();
    }
    setState(() {
      _isLoading = false;
    });
  }

  _buildCancellationReqListBox() {
    return Card(
      color: ColorResources.cardBgColor,
      elevation: .1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child:
      Obx(() {
        if (!_appointmentCancellationController.isError
            .value) { // if no any error
          if (_appointmentCancellationController.isLoading.value) {
            return const ILoadingIndicatorWidget();
          } else {
            return _appointmentCancellationController.dataList.isEmpty
                ? Container()
                : ListTile(
              title: const Text("Lịch sử yêu cầu hủy lịch hẹn",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                ),),
              subtitle: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: _appointmentCancellationController.dataList.length,
                  itemBuilder: (context, index) {
                    AppointmentCancellationRedModel appointmentCancellationRedModel = _appointmentCancellationController
                        .dataList[index];
                    return ListTile(
                      leading: Icon(Icons.circle,
                        size: 10,
                        color: appointmentCancellationRedModel.status ==
                            "Initiated" ? Colors.yellow :
                        appointmentCancellationRedModel.status == "Rejected"
                            ? Colors.red
                            :
                        appointmentCancellationRedModel.status == "Approved"
                            ? Colors.green
                            :
                        appointmentCancellationRedModel.status == "Processing"
                            ? Colors.orange
                            :
                        Colors.grey,),
                      //'Initiated','Rejected','Approved','Processing'
                      title: Text(
                        appointmentCancellationRedModel.status ?? "--",
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500
                        ),),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          appointmentCancellationRedModel.notes == null
                              ? Container()
                              : Text(
                              appointmentCancellationRedModel.notes ?? "--",
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400
                              )
                          ),
                          Text(DateTimeHelper.getDataFormat(
                              appointmentCancellationRedModel.createdAt ??
                                  "--"),
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400
                              )
                          ),
                          Divider(
                            color: Colors.grey.shade100,
                          )
                        ],
                      ),
                    );
                  }

              ),
            );
          }
        } else {
          return Container();
        } //Error svg

      }),

    );
  }
  _buildFileBox() {
    return Card(
      color: ColorResources.cardBgColor,
      elevation: .1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child:
      ListTile(
        trailing: const Icon(Icons.arrow_right,
        color: ColorResources.iconColor,
        size: 30,),
        onTap: (){
          Get.to(()=>PatientFilePage(patientId: appointmentModel?.patientId.toString(),));
        },
        title: const Text("Tệp bệnh án",
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500
          ),),
        subtitle: const Text(
            "Nhấn vào đây để xem tệp bệnh án",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,

            )
        )
      ),

    );
  }
  _buildPrescriptionListBox() {
    return Card(
      color: ColorResources.cardBgColor,
      elevation: .1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child:
      ListTile(
        title: const Text("Đơn thuốc",
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500
          ),),
        subtitle: Obx(() {
          if (!_prescriptionController.isError.value) { // if no any error
            if (_prescriptionController.isLoading.value) {
              return const ILoadingIndicatorWidget();
            } else {
              return _prescriptionController.dataList.isEmpty ? const Text(
                  "Không tìm thấy đơn thuốc!",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,

                  )
              ) :
              ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: _prescriptionController.dataList.length,
                  itemBuilder: (context, index) {
                    PrescriptionModel prescriptionModel = _prescriptionController
                        .dataList[index];
                    return ListTile(
                      trailing: const Icon(Icons.download,size: 20,
                      color: ColorResources.iconColor,
                      ),
                      onTap: () async {
                        if(prescriptionModel.pdfFileUrl!=null&&prescriptionModel.pdfFileUrl!="")
                        {
                          await launchUrl(Uri.parse(
                              "${ApiContents.imageUrl}/${prescriptionModel
                                  .pdfFileUrl}"),
                              mode: LaunchMode.externalApplication
                          );
                        }
                        else{
                          await launchUrl(Uri.parse(
                              "${ApiContents.prescriptionUrl}/${prescriptionModel
                                  .id}"),
                              mode: LaunchMode.externalApplication
                          );
                        }
                      },
                      title: Text("Đơn thuốc #${prescriptionModel.id ??
                          "--"}",
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500
                        ),),
                      subtitle: const Text(
                              "Nhấn vào đây để tải đơn thuốc",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400
                          )
                      ),
                    );
                  }

              );
            }
          } else {
            return Container();
          } //Error svg

        }),
      ),

    );
  }

  void getAndSetQueue() async {
    if (appointmentModel == null) return;
    setState(() {
      _isLoadingQueue = true;
    });
    final res = await AppointmentCheckinService.getData(
        doctId: appointmentModel!.doctorId.toString(),
        date: appointmentModel?.date ?? "");
    if (res != null) {
      for (int i = 0; i < res.length; i++) {
        if (res[i].appointmentId == appointmentModel?.id) {
          _queueNumber = i + 1;
          break;
        }
      }
    } else {
      _queueNumber = null;
    }
    setState(() {
      _isLoadingQueue = false;
    });
  }

  void openBoxToCheckIn() {
    showModalBottomSheet(
      backgroundColor: ColorResources.bgColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.8,
                  decoration: const BoxDecoration(
                    color: ColorResources.bgColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20.0),
                      topLeft: Radius.circular(20.0),
                    ),
                  ),
                  //  height: 260.0,
                  child: Stack(
                    children: [
                      Positioned(
                          top: 20,
                          left: 5,
                          right: 5,
                          bottom: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(ImageConstants.checkImageBox,
                                height: 80,
                                width: 80,
                              ),
                              const SizedBox(height: 30),
                              Text("Mã lịch hẹn - ${widget.appId}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14
                                  )
                              ),
                              const SizedBox(height: 5),
                              Text("Loại lịch hẹn - ${appointmentModel?.type ??
                                  "--"}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14
                                  )
                              ),
                              const SizedBox(height: 5),
                              Text("Ngày - ${DateTimeHelper.getDataFormat(
                                  appointmentModel?.date ?? "")}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14
                                  )
                              ),
                              const SizedBox(height: 5),
                              Text("Thời gian  - ${DateTimeHelper
                                  .convertTo12HourFormat(
                                  appointmentModel?.timeSlot ?? "")}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14
                                  )
                              ),
                              const Padding(
                                padding: EdgeInsets.all(20),
                                child: Divider(),
                              ),
                              QRCode(
                                  size: 300,
                                  data: getQrCodeData()

                              ),
                              const Text(
                                  "Đến phòng khám và quét mã QR để tự động tạo số hàng đợi của bạn.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14
                                ),
                              )
                            ],
                          )
                      ),
                    ],
                  )
              );
            }
        );
      },
    ).whenComplete(() {

    });
  }
  String getQrCodeData() {
    final qrData = {
      "appointment_id": widget.appId,
      "date": appointmentModel?.date,
      "time": appointmentModel?.timeSlot
    };
    return jsonEncode(qrData);

  }

}