import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laundry_firebase/pages/queue_mobile.dart';
import 'package:laundry_firebase/variables/variables.dart';

class MyQueue extends StatefulWidget {
  const MyQueue({super.key});

  @override
  State<MyQueue> createState() => _MyQueueState();
}

class _MyQueueState extends State<MyQueue> {
  @override
  void initState() {
    super.initState();

    putEntries();
  }

  //textcontrollers
  TextEditingController jobidController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController productController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  TextEditingController customerController = TextEditingController();
  TextEditingController initialLoadController = TextEditingController();
  TextEditingController initialPriceController = TextEditingController();
  TextEditingController queueStatController = TextEditingController();
  TextEditingController paymentStatController = TextEditingController();
  TextEditingController paymentReceivedByController = TextEditingController();
  TextEditingController needOnController = TextEditingController();
  TextEditingController riderDeliverController = TextEditingController();
  TextEditingController riderPickupController = TextEditingController();
  TextEditingController actRiderDeliverController = TextEditingController();
  TextEditingController actRiderPickupController = TextEditingController();

  TextEditingController kulangController = TextEditingController();
  TextEditingController maySukliController = TextEditingController();

  final Color _gcButtons = Color.fromRGBO(134, 218, 252, 0.733);

  int _initialJob = 0,
      _initialSelection = 0,
      _initialDet = 0,
      _initialFab = 0,
      _initialBle = 0,
      _initialOth = 0,
      _initialCount = -1;

  String _sCreatedBy = "Jeng";
  String _sCustomer = "xxx";
  int _iInitialLoad = 0;
  int _iInitialPrice = 0;
  late String _sQueueStatus;
  late String _sPaymentStatus;
  late String _sPaymentReceivedBy;
  late DateTime _dNeedOn = DateTime.now().add(Duration(minutes: 210));
  late String _sNeedOn;
  bool _bMaxFab = false;
  bool _bFold = true;
  bool _bMix = true;
  int _iBasket = 0;
  int _iBag = 0;
  int _iKulang = 0;
  int _iMaySukli = 0;
  //
  final _formKey = GlobalKey<FormState>();

  String selectedValue = 'Option 1';

  //open new expense box
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "New Laundry ${DateTime.now().toString().substring(5, 13)}",
          style: TextStyle(backgroundColor: Colors.amber[300]),
        ),
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2.0)),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    //QueueStat
                    DropdownMenu(
                      label: Text("Status",
                          style: TextStyle(
                            fontSize: 12.0,
                          )),
                      inputDecorationTheme: getThemeDropDown(),
                      controller: queueStatController,
                      hintText: "Status",
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(
                            value: "ForSorting", label: "ForSorting"),
                        DropdownMenuEntry(
                            value: "RiderPickup", label: "RiderPickup"),
                      ],
                      onSelected: (val) {
                        setState(() {
                          _sQueueStatus = val.toString();
                        });
                      },
                      initialSelection: "ForSorting",
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Customer Name
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: TextFormField(
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s\b\w*'))
                        ],
                        textAlign: TextAlign.center,
                        controller: customerController,
                        decoration: InputDecoration(
                            labelText: 'Customer Name',
                            hintText: 'Enter Customer Name'),
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Required";
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //InitialLoad Estimate Load
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() => _iInitialLoad--);
                            },
                            icon: const Icon(Icons.remove),
                            color: Colors.blueAccent,
                          ),
                          Text("Estimated Load: $_iInitialLoad"),
                          IconButton(
                            onPressed: () {
                              setState(() => _iInitialLoad++);
                            },
                            icon: const Icon(Icons.add),
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                    //Initial Price
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textAlign: TextAlign.center,
                        controller: initialPriceController,
                        decoration: InputDecoration(
                            labelText: 'Estimated Price',
                            hintText: 'Initial Price'),
                        validator: (val) {},
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Basket
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() => _iBasket--);
                            },
                            icon: const Icon(Icons.remove),
                            color: Colors.blueAccent,
                          ),
                          Text("Basket: $_iBasket"),
                          IconButton(
                            onPressed: () {
                              setState(() => _iBasket++);
                            },
                            icon: const Icon(Icons.add),
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Bag
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() => _iBag--);
                            },
                            icon: const Icon(Icons.remove),
                            color: Colors.blueAccent,
                          ),
                          Text("Bag: $_iBag"),
                          IconButton(
                            onPressed: () {
                              setState(() => _iBag++);
                            },
                            icon: const Icon(Icons.add),
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Payment
                    DropdownMenu(
                      label: Text("Payment",
                          style: TextStyle(
                            fontSize: 12.0,
                          )),
                      inputDecorationTheme: getThemeDropDown(),
                      controller: paymentStatController,
                      hintText: "Payment",
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(value: "Unpaid", label: "Unpaid"),
                        DropdownMenuEntry(value: "PaidCash", label: "PaidCash"),
                        DropdownMenuEntry(
                            value: "PaidGcash", label: "PaidGcash"),
                        DropdownMenuEntry(
                            value: "WaitingGcash", label: "WaitingGcash"),
                        DropdownMenuEntry(value: "Kulang", label: "Kulang"),
                        DropdownMenuEntry(value: "MaySukli", label: "MaySukli"),
                      ],
                      onSelected: (val) {},
                      initialSelection: "Unpaid",
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Payment Received By
                    DropdownMenu(
                      label: Text("Payment Received By",
                          style: TextStyle(
                            fontSize: 12.0,
                          )),
                      inputDecorationTheme: getThemeDropDown(),
                      controller: paymentReceivedByController,
                      hintText: "Select Staff",
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(value: "N/a", label: "N/a"),
                        DropdownMenuEntry(value: "Jeng", label: "Jeng"),
                        DropdownMenuEntry(value: "Abi", label: "Abi"),
                        DropdownMenuEntry(value: "Ket", label: "Ket"),
                        DropdownMenuEntry(value: "DonP", label: "DonP"),
                        DropdownMenuEntry(value: "Rowel", label: "Rowel"),
                        DropdownMenuEntry(value: "Seigi", label: "Seigi"),
                        DropdownMenuEntry(value: "Let", label: "Let"),
                      ],
                      onSelected: (val) {
                        setState(() {});
                      },
                      initialSelection: "N/a",
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Need On Date +
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(0, 212, 212, 212),
                                    width: 0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("-1 day"),
                                IconButton(
                                  onPressed: () {
                                    setState(() => _dNeedOn =
                                        _dNeedOn.add(Duration(days: -1)));
                                  },
                                  icon:
                                      const Icon(Icons.remove_circle_outlined),
                                  color: Colors.blueAccent,
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() => _dNeedOn =
                                        _dNeedOn.add(Duration(days: 1)));
                                  },
                                  icon: const Icon(Icons.add_circle),
                                  color: Colors.blueAccent,
                                ),
                                Text("+1 day"),
                              ],
                            ),
                          ),
                          //Need On date?
                          Container(
                            padding: EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(0, 212, 212, 212),
                                    width: 0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Need On: ${_dNeedOn.toString().substring(5, 14)}00",
                                ),
                              ],
                            ),
                          ),
                          //Need On Date +
                          Container(
                            padding: EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(0, 212, 212, 212),
                                    width: 0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("-1 hr"),
                                IconButton(
                                  onPressed: () {
                                    setState(() => _dNeedOn =
                                        _dNeedOn.add(Duration(hours: -1)));
                                  },
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.blueAccent,
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() => _dNeedOn =
                                        _dNeedOn.add(Duration(hours: 1)));
                                  },
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: Colors.blueAccent,
                                ),
                                Text("+1 hr"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Max Fab?
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Reg Fab"),
                          Switch.adaptive(
                            value: _bMaxFab,
                            onChanged: (bool value) {
                              setState(() {
                                _bMaxFab = value;
                              });
                            },
                          ),
                          Text("Max 100ml"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //No Fold
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("No Fold"),
                          Switch.adaptive(
                            value: _bFold,
                            onChanged: (bool value) {
                              setState(() {
                                _bFold = value;
                              });
                            },
                          ),
                          Text("Fold"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Dont mix
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Dont Mix"),
                          Switch.adaptive(
                            value: _bMix,
                            onChanged: (bool value) {
                              setState(() {
                                _bMix = value;
                              });
                            },
                          ),
                          Text("Mix"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Kulang
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textAlign: TextAlign.center,
                        controller: kulangController,
                        decoration: InputDecoration(
                            labelText: 'Kulang bayad',
                            hintText: 'Magkano kulang?'),
                        validator: (val) {},
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //May Sukli
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textAlign: TextAlign.center,
                        controller: maySukliController,
                        decoration: InputDecoration(
                            labelText: 'May Sukli', hintText: 'Magkano sukli?'),
                        validator: (val) {},
                      ),
                    ),

                    //Submit
                    /*
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate returns true if the form is valid, or false otherwise.
                          if (_formKey.currentState!.validate()) {
                            // If the form is valid, display a snackbar. In the real world,
                            // you'd often call a server or save the information in a database.
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Processing Data' + )),
                            );
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ), */
                  ],
                ),
              ),
            );
          }),
        ),
        actions: [
          //cancel button
          _cancelButton(),

          //save button
          _createNewRecord(),
        ],
      ),
    );
  }

  reopenBox() {
//pop box
    Navigator.pop(context);

    //clear controllers
    //productController.clear();
    typeController.clear();
    //amountController.clear();
    //remarkController.clear();
    openNewExpenseBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //body: Text("watata"),
      body: MyQueueMobile(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openNewExpenseBox();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _cancelButton() {
    return MaterialButton(
        onPressed: () {
          //pop box
          Navigator.pop(context);

          //clear controllers
          productController.clear();
          amountController.clear();
          remarkController.clear();
        },
        color: _gcButtons,
        child: const Text("Cancel"));
  }

  Widget _createNewRecord() {
    return MaterialButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          // If the form is valid, display a snackbar. In the real world,
          // you'd often call a server or save the information in a database.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Processing Data')),
          );

          //pop box
          Navigator.pop(context);

          insertDataJobsOnQueue(
            _sCreatedBy,
            customerController.text,
            _iInitialLoad,
            int.parse(initialPriceController.text.isEmpty
                ? "0"
                : initialPriceController.text),
            queueStatController.text,
            paymentStatController.text,
            paymentReceivedByController.text,
            _dNeedOn,
            _bMaxFab,
            _bFold,
            _bMix,
            _iBasket,
            _iBag,
            int.parse(
                kulangController.text.isEmpty ? "0" : kulangController.text),
            int.parse(maySukliController.text.isEmpty
                ? "0"
                : maySukliController.text),
          );
        }
      },
      color: _gcButtons,
      child: const Text("Save"),
    );
  }

  void messageResult(BuildContext context, String sMsg) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(sMsg),
              actions: [
                MaterialButton(
                  onPressed: () => Navigator.pop(context),
                  color: _gcButtons,
                  child: const Text("Ok"),
                ),
              ],
            ));
  }

  //insert
  void insertData(int jobid, String sType, int id, int count) {
    //insert
    CollectionReference collRef =
        FirebaseFirestore.instance.collection('ProductsUsed');
    collRef
        .add({
          'jobid': jobid,
          'Id': id,
          'Count': count,
          'Type': sType,
          'Date': DateTime.now(),
        })
        .then((value) => {
              messageResult(context, "Insert Done."),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError((error) => messageResult(context, "Failed : $error"));

    //re-read
  }

  //insert

  void insertDataJobsOnQueue(
      String sCreatedBy,
      String sCustomer,
      int iInitialLoad,
      int iInitialPrice,
      String sQueueStatus,
      String sPaymentStatus,
      String sPaymentReceivedBy,
      DateTime dNeedOn,
      bool bMaxFab,
      bool bFold,
      bool bMix,
      int iBasket,
      int iBag,
      int iKulang,
      int iMaySukli) {
    //insert
    CollectionReference collRef =
        FirebaseFirestore.instance.collection('JobsOnQueue');
    collRef
        .add({
          'DateQ': DateTime.now(),
          'CreatedBy': sCreatedBy,
          'Customer': sCustomer,
          'InitialLoad': iInitialLoad,
          'InitialPrice': iInitialPrice,
          'QueueStat': sQueueStatus,
          'PaymentStat': sPaymentStatus,
          'PaymentReceivedBy': sPaymentReceivedBy,
          'NeedOn': dNeedOn,
          'MaxFab': bMaxFab,
          'Fold': bFold,
          'Mix': bMix,
          'Basket': iBasket,
          'Bag': iBag,
          'Kulang': iKulang,
          'MaySukli': iMaySukli,
        })
        .then((value) => {
              _sCreatedBy = "",
              customerController.clear(),
              _iInitialLoad = 0,
              initialPriceController.clear(),
              queueStatController.clear(),
              paymentStatController.clear(),
              paymentReceivedByController.clear(),
              dNeedOn = DateTime.now(),
              _bMaxFab = false,
              _bFold = true,
              _bMix = true,
              _iBasket = 0,
              _iBag = 0,
              kulangController.clear(),
              maySukliController.clear(),
              messageResult(context, "Insert Done." + sCustomer),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError((error) => messageResult(context, "Failed : $error"));

    //re-read
  }

  getThemeDropDown() {
    return InputDecorationTheme(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      constraints: BoxConstraints.tight(const Size.fromHeight(40)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
