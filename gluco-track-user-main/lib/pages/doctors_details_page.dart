import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:star_rating/star_rating.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:userapp/model/doctors_review_model.dart';
import 'package:userapp/pages/full_screen_image_viewer_page.dart';
import 'package:userapp/pages/stripe_payment_page.dart';
import '../controller/boked_time_slot_controller.dart';
import '../controller/time_slots_controller.dart';
import '../helpers/route_helper.dart';
import '../model/booked_time_slot_mdel.dart';
import '../model/time_slots_model.dart';
import '../model/user_model.dart';
import '../pages/razor_pay_payment_page.dart';
import '../services/appointment_service.dart';
import '../services/coupon_service.dart';
import '../services/doctor_service.dart';
import '../services/family_members_service.dart';
import '../services/stripe_service.dart';
import '../services/user_service.dart';
import '../utilities/app_constans.dart';
import '../widget/loading_Indicator_widget.dart';
import '../helpers/date_time_helper.dart';
import '../helpers/theme_helper.dart';
import '../model/doctors_model.dart';
import '../model/family_members_model.dart';
import '../services/payment_gateway_service.dart';
import '../services/razor_pay_service.dart';
import '../utilities/api_content.dart';
import '../utilities/colors_constant.dart';
import '../utilities/image_constants.dart';
import '../widget/app_bar_widget.dart';
import '../widget/button_widget.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:intl/intl.dart';
import '../widget/image_box_widget.dart';
import '../widget/toast_message.dart';
import 'package:country_picker/country_picker.dart';

class DoctorsDetailsPage extends StatefulWidget {
  final String? doctId;
  const DoctorsDetailsPage({super.key,required this.doctId});

  @override
  State<DoctorsDetailsPage> createState() => _DoctorsDetailsPageState();
}

class _DoctorsDetailsPageState extends State<DoctorsDetailsPage> {
  UserModel? userModel;
  ScrollController scrollController=ScrollController();
  String _selectedDate="";
  String _setTime="";
  String _endTime="";
  String phoneCode="+";
  DoctorsModel? _doctorsModel;
  String _selectedAppointmentType="0";
  List<FamilyMembersModel> familyModelList=[];
  FamilyMembersModel? selectedFamilyMemberModel;
  int payNow=1;
  bool couponEnable=false;
  double appointmentFee=0;
  double totalAmount=0;
  double offPrice=0;
  int? couponId;
  double? couponValue;
  double tax=0;
  double unitTaxAmount=0;
  double unitTotalAmount=0;
  String? activePaymentGatewayName;
  String? activePaymentGatewayKey;
  String? activePaymentGatewaySecret;
  List<DoctorsReviewModel> doctorReviewModel=[];

  final List _gridData=[
    {
      "title":"Bệnh viện",
      "icon":Icons.handshake,
      "id":"1"
    },
    {
      "title":"Video hỗ trợ",
      "icon":Icons.videocam_rounded,
      "id":"2"
    },
    {
      "title":"Khẩn cấp",
      "icon":Icons.emergency,
      "id":"3"
    }
  ];
  final TextEditingController _mobileController=TextEditingController();
  final TextEditingController _fNameController=TextEditingController();
  final TextEditingController _lNameController=TextEditingController();
  final TextEditingController _couponNameController=TextEditingController();

  final GlobalKey<FormState> _formKey2 =  GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading=false;
  final DateTime _todayDayTime=DateTime.now();
  final TimeSlotsController _timeSlotsController = Get.put(TimeSlotsController());
  final BookedTimeSlotsController _bookedTimeSlotsController = Get.put(BookedTimeSlotsController());
  double? clinicVisitFee;
  double? clinicVisitServiceCharge;
  double? videoFee;
  double? videoServiceCharge;
  double? emergencyFee;
  double? emergencyServiceCharge;
  bool stopBooking=false;

  @override
  void initState() {
    phoneCode=AppConstants.defaultCountyCode;
    // TODO: implement initState
    getAndSetData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
          backgroundColor:  ColorResources.bgColor,
        appBar: IAppBar.commonAppBar(title: "Đặt lịch hẹn"),
        body:   _doctorsModel==null||_isLoading?const ILoadingIndicatorWidget():_buildBody(_doctorsModel!)

      );
  }

  _buildBody( DoctorsModel doctorsModel) {
    return SafeArea(
      child:
      ListView(
        padding: const EdgeInsets.all(8),
        children: [
          _buildProfileSection(),
         // _buildExReCard(),
          _buildClinicInfo(),
          _doctorsModel==null|| _doctorsModel?.clinicImage==null||_doctorsModel!.clinicImage!.isEmpty?Container():_buildImageClinic(_doctorsModel?.clinicImage??[]),
          const SizedBox(height: 10),
          _buildFamilyMemberCard(),
          const SizedBox(height: 10),
          const  ListTile(title: Text("Lịch hẹn",
              style:  TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16
              )),

          ),
          buildOpBtn(doctorsModel),
         _selectedAppointmentType=="0"?Container(): buildOpDetails(),
          doctorReviewModel.isEmpty?Container(): _buildRatingReviewBox(),
          const SizedBox(height: 10),
          doctorsModel.desc==null?Container(): buildTitleAndDesBox("Giới thiệu",doctorsModel.desc??""),
          // _buildVideoBg()

        ],
      ),
    );
  }
  _buildProfileSection() {
    return  Card(
      color:  ColorResources.cardBgColor,
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
                    flex:2,
                    child: Stack(
                      children: [
                        _doctorsModel!.image==null|| _doctorsModel!.image==""? const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 30,
                          child: Icon(Icons.person,
                            size: 40,),
                        ):   ClipOval(child:
                        SizedBox(
                          height: 80,
                          width: 80,
                          child: CircleAvatar(child:ImageBoxFillWidget(
                            imageUrl:
                            "${ApiContents.imageUrl}/${_doctorsModel!.image}",
                            boxFit: BoxFit.fill,
                          )),
                        ),
                        ),

                        const Positioned(
                          top: 5,
                          right: 0,
                          child:  CircleAvatar(backgroundColor: Colors.white,radius: 8,
                            child:CircleAvatar(backgroundColor: Colors.green,radius: 6),),
                        )
                      ],
                    )),
                const SizedBox(width: 20),
                Flexible(
                    flex:6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text("${_doctorsModel?.fName??"--"} ${_doctorsModel?.lName??"--"}",
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                          ),),
                        const SizedBox(height: 5),
                         Text(_doctorsModel?.specialization??"",
                          style: const TextStyle(
                              color: ColorResources.secondaryFontColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12
                          ),),
                        const SizedBox(height: 5),
                        Row(
                          children:[
                            StarRating(
                              mainAxisAlignment: MainAxisAlignment.center,
                              length: 5,
                              color:  _doctorsModel?.averageRating==0?Colors.grey:Colors.amber,
                              rating: _doctorsModel?.averageRating??0,
                              between: 5,
                              starSize: 15,
                              onRaitingTap: (rating) {
                              },
                            ),
                            const  SizedBox(width: 10),
                            Text("${_doctorsModel?.averageRating} (${_doctorsModel?.numberOfReview} Review)",
                              style: const TextStyle(
                                  color: ColorResources.secondaryFontColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12
                              ),)
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children:[
                            const  Icon(FontAwesomeIcons.briefcase,color: ColorResources.iconColor,size: 15),
                            const  SizedBox(width: 5),
                            Text("Kinh nghiệm ${_doctorsModel?.exYear??"--"} năm",
                              style:const TextStyle(
                                  color: ColorResources.secondaryFontColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12
                              ),)],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children:  [
                            const   Icon(FontAwesomeIcons.circleCheck,color: ColorResources.btnColorGreen,size: 15),
                            const   SizedBox(width: 5),
                            Text("${_doctorsModel?.totalAppointmentDone??"0"} Lịch hẹn đã đặt",
                              style: const TextStyle(
                                  color: ColorResources.secondaryFontColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12
                              ),)],
                        ),
                        _buildSocialMediaSection()
                      ],))
              ],
            ),
            const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }

  buildTitleAndDesBox(String title,String subTitle) {
    return  ListTile(
      title:  Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16
        ),),
      subtitle: Text(subTitle,
        style: const TextStyle(
            color: ColorResources.secondaryFontColor,
            fontWeight: FontWeight.w400,
            fontSize: 13
        ),),
    );
  }

  buildOpBtn(DoctorsModel doctorsModel) {
    return     GridView.builder(
        controller: scrollController,
        padding:const EdgeInsets.all(0),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 5,
            mainAxisSpacing: 20
        ),
        itemCount: 3,
        itemBuilder: (context,index){
          return GestureDetector(
            onTap: getCheckVisibility(doctorsModel,_gridData[index]['id'])?
                (){
                  _selectedAppointmentType = _gridData[index]['id'];
                  appointmentFee=getFeeFilter(_gridData[index]['id']);
                  amtCalculation();
                  _setTime = "";
                  _endTime="";

              setState(() {

              });
            }:null,
            child: Card(
                  elevation: getCheckVisibility(doctorsModel,_gridData[index]['id'])?1:0,
                color:_selectedAppointmentType == _gridData[index]['id']?ColorResources.primaryColor:ColorResources.cardBgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(_gridData[index]['icon'],
                        size: 40,
                        color:!getCheckVisibility(doctorsModel,_gridData[index]['id'])?Colors.grey:_selectedAppointmentType== _gridData[index]['id']?Colors.white:ColorResources.primaryColor,),
                      const SizedBox(height: 5),
                      Text(_gridData[index]['title']=="Video hỗ trợ"?"Video hỗ trợ":_gridData[index]['title'],
                        textAlign: TextAlign.center,
                        style:  TextStyle(
                            color:!getCheckVisibility(doctorsModel,_gridData[index]['id'])?Colors.grey: _selectedAppointmentType== _gridData[index]['id']?Colors.white:ColorResources.primaryFontColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w400
                        ),),
                      Text("Phí ${getFeeFilter(_gridData[index]['id'])} ${AppConstants.appCurrency}",
                        style:  TextStyle(
                            color:!getCheckVisibility(doctorsModel,_gridData[index]['id'])?Colors.grey: _selectedAppointmentType== _gridData[index]['id']?Colors.white:ColorResources.primaryFontColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500
                        ),),
                    ],
                  ),
                )
            ),
          );

        });
  }

  buildOpDetails() {
    return Padding(
      padding: const EdgeInsets.only(top:10.0),
      child: Card(
        color: ColorResources.cardBgColor,
        elevation: .1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(getAppTypeName(_selectedAppointmentType),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600
                    ),),

                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                children: [
                  _selectedAppointmentType=="3"?Container():     Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Ngày",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12
                          ),),
                        GestureDetector(
                          onTap: (){
                            _timeSlotsController.getData(widget.doctId??"", DateTimeHelper.getDayName(_todayDayTime.weekday),_selectedAppointmentType);
                            _bookedTimeSlotsController.getData(widget.doctId??"", DateTimeHelper.getYYYMMDDFormatDate(_todayDayTime.toString()),getAppTypeName(_selectedAppointmentType));
                            _openBottomSheet();
                          },
                          child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              color: ColorResources.cardBgColor,
                              elevation: .1,
                              child: ListTile(
                                title:   Text(_selectedDate==""?"--":DateTimeHelper.getDataFormat(_selectedDate),
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
                                        color: Colors.white,),
                                    )),
                              )),
                        )
                      ],
                    ),
                  ),
                  _selectedAppointmentType=="3"?Container():    Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Thời gian",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12
                          ),),
                        GestureDetector(
                          onTap: (){
                            _timeSlotsController.getData(widget.doctId??"", DateTimeHelper.getDayName(_todayDayTime.weekday),_selectedAppointmentType);
                            _bookedTimeSlotsController.getData(widget.doctId??"", DateTimeHelper.getYYYMMDDFormatDate(_todayDayTime.toString()),getAppTypeName(_selectedAppointmentType));
                            _openBottomSheet();
                          },
                          child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              color: ColorResources.cardBgColor,
                              elevation: .1,
                              child: ListTile(
                                title:   Text(_setTime==""?"--":DateTimeHelper.convertTo12HourFormat(_setTime),
                                  style:const  TextStyle(
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
              _doctorsModel?.stopBooking==1|| stopBooking?Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                      color: Colors.red,
                    size: 20,),
                    const SizedBox(width: 10,),
                    Flexible(
                      child: Text("Lỗi, bác sĩ không nhận lịch hẹn tại thời điểm này.",
                      style: TextStyle(
                        color: Colors.red
                      ),
                      ),
                    ),
                  ],
                ),
              ):Container(),
              SmallButtonsWidget(title: "Đặt lịch hẹn", onPressed:_doctorsModel?.stopBooking==1|| stopBooking?null:(){
                if(_selectedAppointmentType=="3"){
                  if(selectedFamilyMemberModel!=null){
                    openAppointmentBox();
                  }else{
                    if(familyModelList.isEmpty){
                      _openBottomSheetAddPatient();
                    }else{
                      _openBottomSheetPatient();
                    }
                  }
                }else{
                  if(_selectedDate==""||_setTime==""){
                    _timeSlotsController.getData(widget.doctId??"", DateTimeHelper.getDayName(_todayDayTime.weekday),_selectedAppointmentType);
                    _bookedTimeSlotsController.getData(widget.doctId??"", DateTimeHelper.getYYYMMDDFormatDate(_todayDayTime.toString()),getAppTypeName(_selectedAppointmentType));
                    _openBottomSheet();
                    return ;
                  }else if(_selectedDate!=""&&_setTime!=""){
                    if(selectedFamilyMemberModel!=null){
                      openAppointmentBox();
                    }else{
                      if(familyModelList.isEmpty){
                        _openBottomSheetAddPatient();
                      }else{
                        _openBottomSheetPatient();
                      }
                    }
                    //Named(RouteHelper.getPatientListPageRoute());
                  }
                }

              }),
              const SizedBox(height: 10),
            ],

          ),
        ),
      ),
    );
  }
   _openBottomSheetPatient(){
    return
      showModalBottomSheet(
        backgroundColor:  ColorResources.bgColor,

        isScrollControlled: true,
        shape:  RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, setState) {
                return Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    decoration: const BoxDecoration(
                      color: ColorResources.bgColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0),
                      ),
                    ),
                    //  height: 260.0,
                    child:Stack(
                      children: [
                        Positioned(
                            top: 10,
                            right: 20,
                            left: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("Thêm/Chọn thành viên gia đình",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600
                                  ),),
                                GestureDetector(
                                  onTap: (){
                                    Get.back();
                                      _openBottomSheetAddPatient();
                                  },
                                  child: Card(
                                    color: ColorResources.btnColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Thêm mới",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500
                                      )),
                                    ),
                                  ),
                                )
                              ],
                            )),

                        Positioned(
                            top: 60,
                            left: 5,
                            right: 5,
                            bottom: 0,
                            child: ListView(
                              children: [
                                ListView.builder(
                                shrinkWrap: true,
                                itemCount: familyModelList.length,
                                itemBuilder: (context,index){
                                  FamilyMembersModel familyModel = familyModelList[index];
                                  return Card(
                                      color: ColorResources.cardBgColor,
                                      elevation: .1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      child: ListTile(
                                        onTap: (){
                                          selectedFamilyMemberModel=familyModel;
                                          this.setState((){});
                                          Get.back();
                                          if(_selectedAppointmentType=="3"){
                                            if(selectedFamilyMemberModel!=null){
                                              openAppointmentBox();
                                            }

                                          }
                                          else{

                                            if(_selectedDate==""||_setTime==""){
                                              _timeSlotsController.getData(widget.doctId??"", DateTimeHelper.getDayName(_todayDayTime.weekday),_selectedAppointmentType);
                                              _bookedTimeSlotsController.getData(widget.doctId??"", DateTimeHelper.getYYYMMDDFormatDate(_todayDayTime.toString()),getAppTypeName(_selectedAppointmentType));
                                              _openBottomSheet();
                                              return ;
                                            }else if(_selectedDate!=""&&_setTime!=""){
                                              if(selectedFamilyMemberModel!=null){
                                                openAppointmentBox();
                                              }
                                              //Named(RouteHelper.getPatientListPageRoute());
                                            }
                                          }

                                        },
                                        leading:const  Icon(Icons.person),
                                        title: Text("${familyModel.fName} ${familyModel.lName}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15
                                          ),
                                        ),
                                        subtitle:Text("${familyModel.phone}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13
                                          ),
                                        ) ,
                                      ));
                                }),


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
  _openBottomSheet(){
    return
      showModalBottomSheet(
        backgroundColor:  ColorResources.bgColor,
        isScrollControlled: true,
        shape:  RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, setState) {
                return Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    decoration: const BoxDecoration(
                      color: ColorResources.bgColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0),
                      ),
                    ),
                    //  height: 260.0,
                    child:Stack(
                      children: [
                        Positioned(
                            top: 10,
                            right: 20,
                            left: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Chọn ngày và thời gian",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600
                                  ),),
                                IconButton(
                                    onPressed: (){
                                      Get.back();
                                    }, icon: const Icon(Icons.close)),
                              ],
                            )),
                        Positioned(
                            top: 60,
                            left: 5,
                            right: 5,
                            bottom: 0,
                            child: ListView(
                              children: [
                                _buildCalendar(setState),
                                const  Divider(),
                                Obx(() {
                                  if (!_timeSlotsController.isError.value&&!_bookedTimeSlotsController.isError.value) { // if no any error
                                    if (_timeSlotsController.isLoading.value||_bookedTimeSlotsController.isLoading.value) {
                                      return const ILoadingIndicatorWidget();
                                    } else if (_timeSlotsController.dataList.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Text("Lỗi, không có thời gian khả dụng cho ngày đã chọn",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red
                                        ),),
                                      );
                                    }
                                    else {
                                      return
                                        _slotsGridView(setState, _timeSlotsController.dataList, _bookedTimeSlotsController.dataList);
                                    }
                                  }else {
                                    return  const Text("Có lỗi xảy ra");
                                  } //Error svg
                                }
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
  Widget _buildCalendar(setState) {
    return SizedBox(
      height: 100,
      child: DatePicker(
        DateTime.now(),
        initialSelectedDate: DateTime.parse(_selectedDate),
        selectionColor: ColorResources.primaryColor,
        selectedTextColor: Colors.white,
        daysCount: 7,
        onDateChange: (date) {
          // New date selected
          this.setState(() {
            final dateParse =  DateFormat('yyyy-MM-dd').parse((date.toString()));
           // print(dateParse);
           _selectedDate = DateTimeHelper.getYYYMMDDFormatDate(date.toString());
            _timeSlotsController.getData(widget.doctId??"", DateTimeHelper.getDayName(dateParse.weekday),_selectedAppointmentType);
            _bookedTimeSlotsController.getData(widget.doctId??"", _selectedDate,getAppTypeName(_selectedAppointmentType));
          });
          setState(() {});
        },
      ),
    );
  }


  Widget _slotsGridView(setStatem, List<TimeSlotsModel> timeSlots, List<BookedTimeSlotsModel> bookedTimeSlots) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: timeSlots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 2 / 1, crossAxisCount: 3),
      itemBuilder: (BuildContext context, int index) {
        return buildTimeSlots(timeSlots[index].timeStart??"--",timeSlots[index].timeEnd??"--",setState,bookedTimeSlots);
      },
    );
  }
  Widget buildTimeSlots(String timeStart, String timeEnd,setState,bookedTimeSlots) {
    return GestureDetector(
      onTap:DateTimeHelper.checkIfTimePassed(timeStart,_selectedDate)||getCheckBookedTimeSlot(timeStart,bookedTimeSlots)?null:() {
        _setTime = timeStart;
        _endTime=timeEnd;
        setState(() {});
        this.setState(() {

        });
        Get.back();
        if(selectedFamilyMemberModel!=null){
          openAppointmentBox();
        }else{
          if(familyModelList.isEmpty){
            _openBottomSheetAddPatient();
          }else{
            _openBottomSheetPatient();
          }

        }
      },
      child: Card(
        color: DateTimeHelper.checkIfTimePassed(timeStart,_selectedDate)|| getCheckBookedTimeSlot(timeStart,bookedTimeSlots)?Colors.red:_setTime == timeStart
            ? ColorResources.primaryColor
            : Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              "$timeStart - $timeEnd",
              style: TextStyle(
                  color: timeStart == _setTime ? Colors.white : Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  getCheckVisibility(DoctorsModel doctorsModel, String appointmentType) {
    switch (appointmentType) {
      case "1":
        {
          if (doctorsModel.clinicAppointment == 1) {
            return true;
          } else {
            return false;
          }
        }
      case "2":
        {
          if (doctorsModel.videoAppointment == 1) {
            return true;
          } else {
            return false;
          }
        }
      case "3":
        {
          if (doctorsModel.emergencyAppointment == 1) {
            return true;
          } else {
            return false;
          }
        }
      default:
        return false;
    }
  }


  void getAndSetData() async {
    setState(() {
      _isLoading = true;
    });
    _selectedDate = DateTimeHelper.getYYYMMDDFormatDate( DateTime.now().toString());
    final resDoctors = await DoctorsService.getDataById(doctId: widget.doctId);
    if (resDoctors != null) {
      _doctorsModel = resDoctors;
      if (_doctorsModel?.clinicAppointment == 1) {
        _selectedAppointmentType = "1";
      } else if (_doctorsModel?.videoAppointment == 1) {
        _selectedAppointmentType = "2";
      } else if (_doctorsModel?.emergencyAppointment == 1) {
        _selectedAppointmentType = "3";
      }
      final  familyMemberList=await FamilyMembersService.getData();
      if(familyMemberList!=null&&familyMemberList.isNotEmpty){
        familyModelList=familyMemberList;
      }

      clinicVisitFee=_doctorsModel?.opdFee??0;
      clinicVisitServiceCharge=0;

      videoFee=_doctorsModel?.videoFee??0;
      videoServiceCharge=0;

      emergencyFee=_doctorsModel?.emgFee??0;
      emergencyServiceCharge=0;


      final userRes=await UserService.getDataById();
      if(userRes!=null){
        userModel=userRes;
      }
      // final resConfiguration=await ConfigurationService.getDataById(idName: "stop_booking");
      // if(resConfiguration!=null){
      //   if(resConfiguration.value=="true"){
      //     stopBooking=true;
      //   }
      // }
      if(_doctorsModel?.clinicStopBooking==1){
        stopBooking=true;
      }
      if(_doctorsModel?.clinicCouponEnable==1){
        couponEnable=true;
      }
      // final resConfigurationCE=await ConfigurationService.getDataById(idName: "coupon_enable");
      // if(resConfigurationCE!=null){
      //   if(resConfigurationCE.value=="true"){
      //     couponEnable=true;
      //   }
      // }
      if(_doctorsModel?.clinicTax!=null){
        tax = _doctorsModel!.clinicTax!;
      }
      // final resConfigurationTax=await ConfigurationService.getDataById(idName: "tax");
      // if(resConfigurationTax!=null){
      //   if(resConfigurationTax.value!=""&&resConfigurationTax.value!=null){
      //     tax=double.parse(resConfigurationTax.value??"0");
      //   }
      // }
      final activePG=await PaymentGatewayService.getActivePaymentGateway();
      if(activePG!=null){
        activePaymentGatewayName=activePG.title;
        activePaymentGatewaySecret=activePG.secret;
        activePaymentGatewayKey=activePG.key;
      }
      appointmentFee=getFeeFilter(_selectedAppointmentType);
      amtCalculation();
      final resDR=await DoctorsService.getDataDoctorsReview(doctId:widget.doctId);
      if(resDR!=null){
        doctorReviewModel=resDR;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }
  getFamilyMemberListList()async{

    setState(() {
      _isLoading = true;
    });
    final  familyList=await FamilyMembersService.getData();
    if(familyList!=null&&familyList.isNotEmpty){
      familyModelList=familyList;
      selectedFamilyMemberModel=familyList[0];

      if(_selectedAppointmentType=="3"){
        if(selectedFamilyMemberModel!=null){
          openAppointmentBox();
        }
      }else{
        if(_selectedDate==""||_setTime==""){
          _timeSlotsController.getData(widget.doctId??"", DateTimeHelper.getDayName(_todayDayTime.weekday),_selectedAppointmentType);
          _bookedTimeSlotsController.getData(widget.doctId??"", DateTimeHelper.getYYYMMDDFormatDate(_todayDayTime.toString()),getAppTypeName(_selectedAppointmentType));
          _openBottomSheet();
          return ;
        }else if(_selectedDate!=""&&_setTime!=""){
          if(selectedFamilyMemberModel!=null){
            openAppointmentBox();
          }
        }
      }

    }
    setState(() {
      _isLoading = false;
    });
  }

  String getAppTypeName(selectedAppointmentTypeId) {
    switch(selectedAppointmentTypeId){
      case "1":{return "OPD";}
      case "2":{return "Video tư vấn";}
      case "3":{return "Khẩn cấp";}
      default: return "--";
    }
  }

  _buildFamilyMemberCard() {
    return Card(
      color: ColorResources.cardBgColor,
      elevation: .1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child:  ListTile(
        leading:const  Icon(Icons.person,
        size: 20,),
        trailing:
        GestureDetector(
          onTap: (){
            if(familyModelList.isEmpty){
              _openBottomSheetAddPatient();
            }else{
              _openBottomSheetPatient();
            }

          },
          child: Container(
            height: 25,
            width: 25,
            decoration: const BoxDecoration(
              shape: BoxShape.circle, // This makes the container circular
              color: ColorResources.btnColor // Background color of the button
            ),
            child: const Icon(
                Icons.add,
                size: 15,
                color: Colors.white, // Color of the icon
              ),

          ),
        ),
        title:const Text("Bệnh nhân",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500
        ),),
        subtitle: selectedFamilyMemberModel==null?null:Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text("${selectedFamilyMemberModel?.fName??"--"} ${selectedFamilyMemberModel?.lName??"--"}",
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14
            ),),
            const SizedBox(height: 3),
            Text(selectedFamilyMemberModel?.phone??"--",
              style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14
              ),)
          ],
        ),
      ),

    );
  }
  _openBottomSheetAddPatient(){
    return
      showModalBottomSheet(
        backgroundColor:  ColorResources.bgColor,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.0),
            topLeft: Radius.circular(20.0),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, setState) {
                return Padding(
                  padding: MediaQuery
                      .of(context)
                      .viewInsets,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const  Text("Đăng ký thành viên mới",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize:15
                            ),),
                          const SizedBox(height: 20),
                          Container(
                            decoration: ThemeHelper().inputBoxDecorationShaddow(),
                            child: TextFormField(
                              keyboardType: TextInputType.name,
                              validator: ( item){
                                return item!.length>3?null:"Nhập tên";
                              },
                              controller: _fNameController,
                              decoration: ThemeHelper().textInputDecoration('Tên*'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: ThemeHelper().inputBoxDecorationShaddow(),
                            child: TextFormField(
                              keyboardType: TextInputType.name,
                              validator: ( item){
                                return item!.length>3?null:"Nhập họ";
                              },
                              controller: _lNameController,
                              decoration: ThemeHelper().textInputDecoration('Họ'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: ThemeHelper().inputBoxDecorationShaddow(),
                            child:
                            TextFormField(
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                ],
                                keyboardType:Platform.isIOS? const TextInputType.numberWithOptions(decimal: true, signed: true)
                                    : TextInputType.number,
                                validator: (item) {
                                  return item!.length > 5 ? null : "Nhập số điện thoại hợp lệ";
                                },
                                controller: _mobileController,
                                decoration: InputDecoration(
                                  prefixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(width: 9),
                                      GestureDetector(child: Padding(
                                        padding: const EdgeInsets.only(right:8.0),
                                        child:  Text(phoneCode,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black
                                          ),),

                                      ),
                                        onTap: (){
                                          showCountryPicker(
                                            context: context,
                                            showPhoneCode: true, // optional. Shows phone code before the country name.
                                            onSelect: (Country country) {
                                              phoneCode="+${country.phoneCode}";
                                              setState((){});
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  hintText: "Ví dụ 1234567890",
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Colors.grey)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Colors.red, width: 2.0)),
                                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide:const BorderSide(color: Colors.red, width: 2.0)),
                                )
                            ),
                          ),
                          const SizedBox(height: 20),
                          SmallButtonsWidget(title: "Lưu", onPressed: (){
                            if(_formKey.currentState!.validate()){
                              Get.back();
                              handleAddFamilyMemberData();
                            //  handleAddData();
                            }


                          }),
                        ],
                      ),
                    ),
                  ),
                );
              }
          );
        },

      ).whenComplete(() {

      });
  }


  void handleAddFamilyMemberData() async{
    setState(() {
      _isLoading=true;
    });

    final res=await FamilyMembersService.addUser(
        fName: _fNameController.text,
        lName: _lNameController.text,
        isdCode: phoneCode,
        phone: _mobileController.text,
          dob: "",
            gender:"");
    if(res!=null){
      IToastMsg.showMessage("Thành công");
      clearInitData();

      getFamilyMemberListList();

    }else{
      setState(() {
        _isLoading=false;
      });
    }

  }

 double getFeeFilter(gridData) {
    switch (gridData){
      case "1": return clinicVisitFee??0;
      case "2": return videoFee??0;
      case "3": return emergencyFee??0;
      default :return 0;
    }
  }
  String? getServiceChargeFilter(gridData) {
    switch (gridData){
      case "1": return clinicVisitServiceCharge?.toString()??"--";
      case "2": return videoServiceCharge?.toString()??"--";
      case "3": return emergencyServiceCharge?.toString()??"--";
      default :return null;
    }
  }

   openAppointmentBox() {
    return
      showModalBottomSheet(
        backgroundColor:  ColorResources.cardBgColor,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.0),
            topLeft: Radius.circular(20.0),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, setState) {
                return Padding(
                  padding: MediaQuery
                      .of(context)
                      .viewInsets,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 20),
                            Image.asset(ImageConstants.appointmentImage,
                              height: 150,
                              width: 150,),
                            const SizedBox(height: 5),
                                const Text("Chỉ còn một bước nữa\nThanh toán và đặt lịch hẹn của bạn.",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14
                              ),),
                           const  Divider(),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                              const   Text("Bác sĩ:",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500
                                  ),),
                                Text("${_doctorsModel?.fName??"--"} ${_doctorsModel?.lName??"--"}",
                                    style:const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500
                                    ))
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const   Text("Bệnh nhân:",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500
                                  ),),
                                Text("${selectedFamilyMemberModel?.fName??"--"} ${selectedFamilyMemberModel?.lName??"--"}",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500
                                    ))
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                               const  Text("Lịch hẹn:",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500
                                  ),),
                                Text(getAppTypeName(_selectedAppointmentType),
                                    style:const  TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500
                                    ))
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const  Text("Ngày - Thời gian:",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500
                                  ),),
                               _selectedAppointmentType=="3"?
                               Text(DateTimeHelper.getDataFormat(DateTimeHelper.getTodayDateInString()),
                                   style:const  TextStyle(
                                       fontSize: 14,
                                       fontWeight: FontWeight.w500
                                   ))
                                   :
                        
                               Text("${DateTimeHelper.getDataFormat(_selectedDate)} - ${DateTimeHelper.convertTo12HourFormat(_setTime)}",
                                    style:const  TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500
                                    ))
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const  Text("Lịch hẹn:",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500
                                  ),),
                                Text(getAppTypeName(_selectedAppointmentType),
                                    style:const  TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500
                                    ))
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const    Text("Phí lịch hẹn:",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500
                                ),),
                                Text("$appointmentFee ${AppConstants.appCurrency}",
                                    style:const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500
                                    ))
                              ],
                            ),

                            couponValue==null?Container(): Padding(
                              padding: const EdgeInsets.only(top:10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                     Text("Mã giảm giá ($couponValue%)",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500
                                    ),),
                                  Text("-$offPrice",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500
                                      ))
                                ],
                              ),
                            ),
                            tax==0?Container(): Padding(
                              padding: const EdgeInsets.only(top:10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Thuế ($tax%)",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500
                                    ),),
                                  Text("+$unitTaxAmount",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500
                                      ))
                                ],
                              ),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const   Text("Tổng tiền:",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500
                                  ),),
                                Text(totalAmount.toString(),
                                    style:const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500
                                    ))
                              ],
                            ),
                        
                            const SizedBox(height: 10),
                        
                            RadioListTile(value: 1, groupValue: payNow,
                              onChanged: (value){
                                clearCoupon();
                              setState((){
                                payNow=1;
                              });
                              },
                            title:const Text("Thanh toán ngay",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500
                            ),
                            ),
                            ),
                            payNow==1&&couponEnable?
                                    _buildCouponCode(setState)

                                :Container(),


                            _selectedAppointmentType=="1"?      RadioListTile(value: 0, groupValue: payNow,
                              onChanged: (value){
                               // Get.back();
                                clearCoupon();
                                setState((){
                                  payNow=0;
                                });
                           //    openAppointmentBox();

                              },
                                  title:const  Text("Thanh toán tại bệnh viện",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                            ):Container(),
                            RadioListTile(value: 2, groupValue: payNow,
                              onChanged: ((userModel?.walletAmount??0) >= totalAmount)?(value){
                                clearCoupon();
                              setState((){
                                  payNow=2;
                                });
                              }:
                                  (value){
                                    Get.toNamed(RouteHelper.getWalletPageRoute());
                              },
                              title:  Text("Thanh toán từ ví (Số dư khả dụng ${userModel?.walletAmount??0} ${AppConstants.appCurrency})",
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              subtitle:((userModel?.walletAmount??0) >= totalAmount)?Container():
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Số dư trong ví không đủ",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                               Text("Nhấn vào đây để nạp tiền",
                                      style:  TextStyle(
                                      color: ColorResources.btnColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500
                                  )
                                  )
                                ],
                              ),
                            ),

                             SmallButtonsWidget(title:
                             payNow==1? "Thanh toán $totalAmount & Đặt lịch hẹn"
                                 :"Đặt lịch hẹn", onPressed: (){
                              Get.back();
                              final checkTime=DateTimeHelper.checkIfTimePassed(_endTime,_selectedDate);
                              if(checkTime){
                                IToastMsg.showMessage("Thời gian đã qua, vui lòng chọn thời gian khác");
                                _openBottomSheet();
                                return;
                              }

                              if(payNow==1){
                                if(activePaymentGatewayName=="Razorpay"){
                                  createOrder();
                                }
                                else  if(activePaymentGatewayName=="Stripe"){
                                  _nameController.text="${selectedFamilyMemberModel?.fName??" "} ${selectedFamilyMemberModel?.lName??""}";
                                  showStripeDetailsBottomSheet();
                                }
                                else{
                                  IToastMsg.showMessage("Không có cổng thanh toán hoạt động");
                                }

                              }else{
                                handleAddAppointment();
                              }

                            })
                        
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
          );
        },

      ).whenComplete(() {

      });
  }
successPayment(){
  IToastMsg.showMessage("Thành công");
  setState(() {
    _isLoading=false;
  });
  Get.offNamedUntil(RouteHelper.getMyBookingPageRoute(), ModalRoute.withName('/HomePage'));
}

  void createOrder() async{
    setState(() {
      _isLoading=true;
    });
    final res=await RazorPayService.createOrderAppointment(

        familyMemberId:selectedFamilyMemberModel?.id.toString()??"",
        status: "Confirmed",
        date: _selectedAppointmentType=="3"?DateTimeHelper.getTodayDateInString():_selectedDate,
        timeSlots: _selectedAppointmentType=="3"?DateTimeHelper.getTodayTimeInString():_setTime,
        doctId: widget.doctId??"",
        deptId: _doctorsModel?.deptId?.toString()??"",
        type:getAppTypeName(_selectedAppointmentType),
        paymentStatus:payNow==1||payNow==2?"Paid":"Unpaid",
        fee: appointmentFee.toString(),
        serviceCharge: getServiceChargeFilter(_selectedAppointmentType)??"0",
        totalAmount:  totalAmount.toString(),
        invoiceDescription: getAppTypeName(_selectedAppointmentType),
        paymentMethod: "Online",
        isWalletTxn:  payNow==2?"1":"0",
        couponId:couponId==null?"":couponId.toString(),
        couponOffAmount:offPrice.toString() ,
        couponTitle: _couponNameController.text,
        couponValue: couponValue==null?"":couponValue.toString(),
        tax: tax.toString(),
        unitTaxAmount: unitTaxAmount.toString(),
        unitTotalAmount: unitTotalAmount.toString(),
      key: activePaymentGatewayKey??"",
      secret: activePaymentGatewaySecret??""
    );
    if(res!=null){
      if(kDebugMode){
        print("Order Id ${res['id']}");
      }
      final orderId=res['id'];
      if(orderId!=null||orderId!=""){
        final String countryCodeWithNumber="${userModel?.isdcode??""}${userModel?.phone??""}";
        Get.to(()=>RazorPayPaymentPage(
          name: "${userModel?.fName??"Bạn"} ${userModel?.lName??"Bạn"}",
          description: "Lịch hẹn",
          email: userModel?.email??"",
          phone:  countryCodeWithNumber,
          amount: totalAmount.toString(),
          onSuccess: successPayment,
          rzKey: activePaymentGatewayKey,
          rzOrderId:orderId ,
        ));
      }else{
        IToastMsg.showMessage("Đã xảy ra lỗi");
      }
    }
    setState(() {
      _isLoading=false;
    });
  }
  void handleAddAppointment() async {
    setState(() {
      _isLoading=true;
    });

    final res=await AppointmentService.addAppointment(
      familyMemberId:selectedFamilyMemberModel?.id.toString()??"",
         patientId: "",
        status: "Confirmed",
        date: _selectedAppointmentType=="3"?DateTimeHelper.getTodayDateInString():_selectedDate,
        timeSlots: _selectedAppointmentType=="3"?DateTimeHelper.getTodayTimeInString():_setTime,
        doctId: widget.doctId??"",
        deptId: _doctorsModel?.deptId?.toString()??"",
        type:getAppTypeName(_selectedAppointmentType),
        meetingId: "",
        meetingLink: "",
        paymentStatus:payNow==1||payNow==2?"Paid":"Unpaid",
        fee: appointmentFee.toString(),
        serviceCharge: getServiceChargeFilter(_selectedAppointmentType)??"0",
        totalAmount:  totalAmount.toString(),
        invoiceDescription: getAppTypeName(_selectedAppointmentType),
        paymentMethod: "Online",
        paymentTransactionId: payNow==1?"hywv387492":payNow==2?"Wallet":"",
         isWalletTxn:  payNow==2?"1":"0",
          couponId:couponId==null?"":couponId.toString(),
          couponOffAmount:offPrice.toString() ,
          couponTitle: _couponNameController.text,
          couponValue: couponValue==null?"":couponValue.toString(),
          tax: tax.toString(),
          unitTaxAmount: unitTaxAmount.toString(),
         unitTotalAmount: unitTotalAmount.toString()
    );
    if(res!=null){
      IToastMsg.showMessage("Thành công");
      setState(() {
        _isLoading=false;
      });
      Get.offNamedUntil(RouteHelper.getMyBookingPageRoute(), ModalRoute.withName('/HomePage'));
    }else{
      setState(() {
        _isLoading=false;
      });
    }
  }

 bool  getCheckBookedTimeSlot(String timeStart,List<BookedTimeSlotsModel> bookedTimeSlots) {
    bool retuenValue=false;
   for(var element in bookedTimeSlots){
     if(element.timeSlots==timeStart){
       retuenValue=true;
       break;
     }
   }
    return retuenValue;

  }

  void clearInitData() {
    _fNameController.clear();
    _lNameController.clear();
    _mobileController.clear();
  }

  _buildCouponCode(setstate) {
    return    Row(
      children: [
        Flexible(
          flex: 4,
          child: Container(
              decoration: ThemeHelper().inputBoxDecorationShaddow(),
              child: TextFormField(
                keyboardType: TextInputType.name,
                validator: ( item){
                  return item!.length>2?null:"Nhập mã giảm giá nếu có";
                },
                controller: _couponNameController,
                decoration: ThemeHelper().textInputDecoration('Mã giảm giá'),
              )),
        ),
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left:8.0),
            child: SmallButtonsWidget(title: couponValue==null?"Áp dụng":"Xóa", onPressed:
            couponValue==null?  ()async{
              if(_formKey.currentState!.validate()){
                Get.back();
                handelCheckCoupon();
              }

            }:(){
              clearCoupon();
             setState(() {
             });
              Get.back();
              openAppointmentBox();
              IToastMsg.showMessage("Mã giảm giá đã được xóa");
            }

            ),
          ),

        )
      ],
    );
  }

  void handelCheckCoupon()async {
    setState(() {
      _isLoading=true;
    });

    final res=await CouponService.getValidateData(
      title:_couponNameController.text.toUpperCase(),
      clinicId:_doctorsModel?.clinicId.toString()

    );
    if(res!=null&&res['status']==true){
      IToastMsg.showMessage(res['msg']??'Đã xảy ra lỗi');
      final value=res['data']['value'];
      final couponIdGet= res['data']['id'];
      couponValue=value!=null?double.parse(value.toString()):null;
      couponId=couponIdGet!=null?int.parse(couponIdGet.toString()):null;
      amtCalculation();
    } else{
      IToastMsg.showMessage(res['msg']??'Đã xảy ra lỗi');
        clearCoupon();
    }
    setState(() {
      _isLoading=false;
    });
    openAppointmentBox();
  }

  amtCalculation(){
    unitTotalAmount=appointmentFee;
    if(appointmentFee==0){return;}
    if(couponValue!=null){
      offPrice=(appointmentFee*couponValue!)/100;
    }else{
      offPrice=0;
    }
     // totalAmount=appointmentFee-offPrice;
    if(tax!=0){
      unitTaxAmount=(appointmentFee*tax)/100;
      unitTotalAmount=appointmentFee+unitTaxAmount;
    }
    totalAmount=appointmentFee+unitTaxAmount-offPrice;
    setState(() {
    });
  }

  void clearCoupon() {
    couponValue=null;
    couponId=null;
    _couponNameController.clear();
    amtCalculation();
    setState(() {
    });

  }
  void showStripeDetailsBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape:   const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child:
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Form(
                key: _formKey2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text("Vui lòng điền thông tin",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        validator: ( item){
                          return item!.length>3?null:"Nhập tên";
                        },
                        controller: _nameController,
                        decoration: ThemeHelper().textInputDecoration('Tên*'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        validator: ( item){
                          return item!.length>5?null:"Nhập địa chỉ";
                        },
                        controller: _addressController,
                        decoration: ThemeHelper().textInputDecoration('Địa chỉ*'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        validator: ( item){
                          return item!.length>3?null:"Nhập thành phố";
                        },
                        controller: _cityController,
                        decoration: ThemeHelper().textInputDecoration('Thành phố*'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        validator: ( item){
                          return item!.length>3?null:"Nhập tỉnh";
                        },
                        controller: _stateController,
                        decoration: ThemeHelper().textInputDecoration('Tỉnh*'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        validator: ( item){
                          return item!.length>3?null:"Nhập quốc gia";
                        },
                        controller: _countryController,
                        decoration: ThemeHelper().textInputDecoration('Quốc gia*'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SmallButtonsWidget(
                      title: "Tiếp tục thanh toán",
                      onPressed: (){
                        if (_formKey2.currentState!.validate()) {
                          Navigator.pop(context);
                          createOrderStripe();
                        }
                      },
                    )

                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  void createOrderStripe() async{
    setState(() {
      _isLoading=true;
    });

    final res=await StripeService.createOrderAppointment(
      secret:activePaymentGatewaySecret??"",
      name:_nameController.text,
      address:_addressController.text ,
      city:_cityController.text ,
      country:_countryController.text ,
      state: _stateController.text,
        familyMemberId:selectedFamilyMemberModel?.id.toString()??"",
        status: "Confirmed",
        date: _selectedAppointmentType=="3"?DateTimeHelper.getTodayDateInString():_selectedDate,
        timeSlots: _selectedAppointmentType=="3"?DateTimeHelper.getTodayTimeInString():_setTime,
        doctId: widget.doctId??"",
        deptId: _doctorsModel?.deptId?.toString()??"",
        type:getAppTypeName(_selectedAppointmentType),
        paymentStatus:payNow==1||payNow==2?"Paid":"Unpaid",
        fee: appointmentFee.toString(),
        serviceCharge: getServiceChargeFilter(_selectedAppointmentType)??"0",
        totalAmount:  totalAmount.toString(),
        invoiceDescription: getAppTypeName(_selectedAppointmentType),
        paymentMethod: "Online",
        isWalletTxn:  payNow==2?"1":"0",
        couponId:couponId==null?"":couponId.toString(),
        couponOffAmount:offPrice.toString() ,
        couponTitle: _couponNameController.text,
        couponValue: couponValue==null?"":couponValue.toString(),
        tax: tax.toString(),
        unitTaxAmount: unitTaxAmount.toString(),
        unitTotalAmount: unitTotalAmount.toString(),
        key: activePaymentGatewayKey??"",

    );
    if(res!=null){
      if(kDebugMode){
        print("Order Id ${res['id']}");
      }
      final orderId=res['id'];
      if(orderId!=null||orderId!=""){
        Get.to(()=>StripePaymentPage(
          onSuccess: successPayment,
          stripeKey: activePaymentGatewayKey,
          orderId:orderId ,
          name:_nameController.text,
          address:_addressController.text ,
          city:_cityController.text ,
          country:_countryController.text ,
          state: _stateController.text,
          customerId: res['customer_id'] ,
          clientSecret:res['client_secret'] ,
        ));
      }else{
            IToastMsg.showMessage("Đã xảy ra lỗi");
      }
    }
    setState(() {
      _isLoading=false;
    });
  }

  _buildSocialMediaSection() {
    return Padding(padding: const EdgeInsets.only(top: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
      _doctorsModel?.youtubeLink==null||_doctorsModel?.youtubeLink==""?Container():
      GestureDetector(
        onTap: (){
          final url=_doctorsModel?.youtubeLink??"";
          launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication
          );
        },
        child: Image.asset(ImageConstants.youtubeImageBox,
          width: 30,
            height: 30,
          ),
      ),  

        _doctorsModel?.fbLink==null||_doctorsModel?.fbLink==""?Container():    Padding(
          padding: const EdgeInsets.only(left:20.0),
          child:
          GestureDetector(
            onTap: (){
              final url=_doctorsModel?.fbLink??"";
              launchUrl(Uri.parse(url),
                  mode: LaunchMode.externalApplication
              );
            },
            child: Image.asset(ImageConstants.facebookImageBox,
              width: 30,
              height: 30,
            ),
          ),
        ),

        _doctorsModel?.instaLink==null||_doctorsModel?.instaLink==""?Container():   Padding(
          padding: const EdgeInsets.only(left:20.0),
          child:
          GestureDetector(
              onTap: (){
                final url=_doctorsModel?.instaLink??"";
                launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication
                );
              },

            child: Image.asset(ImageConstants.instagramImageBox,
              width: 30,
              height: 30,
            ),
          ),
        ),
        _doctorsModel?.twitterLink==null||_doctorsModel?.twitterLink==""?Container():   Padding(
          padding: const EdgeInsets.only(left:20.0),
          child:
          GestureDetector(
            onTap: (){
              final url=_doctorsModel?.twitterLink??"";
              launchUrl(Uri.parse(url),
                  mode: LaunchMode.externalApplication
              );
            },
            child: Image.asset(ImageConstants.twitterImageBox,
              width: 30,
              height: 30,
            ),
          ),
        )
      ],
    ),
    );
  }
  _buildRatingReviewBox(){
    return Padding(
      padding: const EdgeInsets.only(top:10),
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 150, // Set a maximum height to maintain balance
      ),
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        controller: PageController(viewportFraction: 0.9), // Controls card width
        itemCount: doctorReviewModel.length,
       // controller: PageController(viewportFraction: 0.9), // Controls card width
        itemBuilder: (context,index){
          DoctorsReviewModel doctorsReviewModel=doctorReviewModel[index];
          return SizedBox(
            width:MediaQuery.sizeOf(context).width,
            child: Card(
              color:  ColorResources.cardBgColor,
              elevation: .1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                isThreeLine: true,
                leading: const Padding(
                  padding: EdgeInsets.only(left:8.0),
                  child: Icon(Icons.person,
                  size: 30,
                  ),
                ),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("${doctorsReviewModel.fName} ${doctorsReviewModel.lName}",
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    StarRating(
                      mainAxisAlignment: MainAxisAlignment.start,
                      length: 5,
                      color:  doctorsReviewModel.points==0?Colors.grey:Colors.amber,
                      rating: double.parse((doctorsReviewModel.points??0).toString()),
                      between: 5,
                      starSize: 15,
                      onRaitingTap: (rating) {
                      },
                    ),
                  ],
                ),
                subtitle: Text(doctorsReviewModel.description??"--",
                 maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400
                  ),
                )
                ,
              ),
            ),
          );
        },
      ),
    ),
    );
  }

  _buildClinicInfo() {
    return GestureDetector(
      onTap: (){
        Get.toNamed(RouteHelper.getClinicPageRoute(clinicId:  _doctorsModel?.clinicId.toString()));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        color: ColorResources.cardBgColor,
        elevation: .1,
        child: ListTile(
          leading:    _doctorsModel?.clinicThumbImage==null|| _doctorsModel?.clinicThumbImage==""?
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
                    imageUrl: "${ApiContents.imageUrl}/${_doctorsModel?.clinicThumbImage}",
                    boxFit: BoxFit.fill,
                  ),
                ),
              )
          ),
          title:  Text(_doctorsModel?.clinicTitle??"--",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.w500)),
          subtitle:     Text(_doctorsModel?.clinicAddress??"--",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13,
                  color: ColorResources.secondaryFontColor,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  _buildImageClinic(List clinicImages ) {
    return  Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
        height: 70,
        child: GridView.builder(
          scrollDirection: Axis.horizontal, // Enable horizontal scrolling
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 100, // Max height of each thumbnail
            mainAxisSpacing: 8, // Spacing between thumbnails
            crossAxisSpacing: 8,
          ),
          itemCount: clinicImages.length,
          itemBuilder: (context, index) {

            return GestureDetector(
              onTap: () {
              Get.to(()=>FullScreenImageViewerPage(
                initialIndex: index, images: clinicImages,
                clinicName: _doctorsModel?.clinicTitle,
              ));
              },
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ImageBoxFillWidget(boxFit:BoxFit.cover,imageUrl: "${ApiContents.imageUrl}/${clinicImages[index]['image']}")),
            );
          },
        ),
      ),
    );

  }
}

