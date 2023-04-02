import 'package:flutter/material.dart';
import 'package:nyoba/models/countries_model.dart';
import 'package:nyoba/provider/user_provider.dart';
import 'package:nyoba/widgets/form/textfield_widget.dart';
import 'package:provider/provider.dart';
import '../../app_localizations.dart';
import '../../utils/utility.dart';

class AccountAddressEditScreen extends StatefulWidget {
  final dynamic data;
  final String? title;
  AccountAddressEditScreen({Key? key, this.data, this.title}) : super(key: key);

  @override
  _AccountAddressEditScreenState createState() =>
      _AccountAddressEditScreenState();
}

class _AccountAddressEditScreenState extends State<AccountAddressEditScreen> {
  bool checkedValue = false;
  UserProvider? userProvider;

  TextEditingController controllerName = new TextEditingController();
  TextEditingController controllerSurname = new TextEditingController();
  TextEditingController controllerCompany = new TextEditingController();
  TextEditingController controllerAddress = new TextEditingController();
  TextEditingController controllerAddressOpt = new TextEditingController();
  TextEditingController controllerTown = new TextEditingController();
  TextEditingController controllerPostCode = new TextEditingController();
  TextEditingController controllerPhone = new TextEditingController();
  TextEditingController controllerEmail = new TextEditingController();

  String? country;
  TextEditingController controllerState = new TextEditingController();

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.title!.toLowerCase() == 'billing') {
        final _billing = userProvider!.customerData!.billing;
        controllerName.text = _billing!.firstName ?? "";
        controllerSurname.text = _billing.lastName ?? "";
        controllerCompany.text = _billing.company ?? "";
        controllerAddress.text = _billing.address1 ?? "";
        controllerAddressOpt.text = _billing.address2 ?? "";
        controllerTown.text = _billing.city ?? "";
        controllerPostCode.text = _billing.postcode ?? "";
        controllerPhone.text = _billing.phone ?? "";
        controllerEmail.text = _billing.email ?? "";

        country = _billing.country;
        if (_billing.country != null) {
          context.read<UserProvider>().setCountries(_billing.country);
          context.read<UserProvider>().setStates(_billing.state);
        }
        controllerState.text = _billing.state ?? "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false);

    var save = () async {
      this.setState(() {});
      if (widget.title!.toLowerCase() == 'billing') {
        await context
            .read<UserProvider>()
            .saveAddress(
              context,
              action: 'billing',
              billingaddress: controllerAddress.text,
              billingaddressopt: controllerAddressOpt.text,
              billingcity: controllerTown.text,
              billingcompany: controllerCompany.text,
              billingcountry: country,
              billingemail: controllerEmail.text,
              billingname: controllerName.text,
              billingphone: controllerPhone.text,
              billingpostal: controllerPostCode.text,
              billingsurname: controllerSurname.text,
              billingstate: controllerState.text,
            )
            .then((value) => this.setState(() {}));
      } else {
        await context
            .read<UserProvider>()
            .saveAddress(context)
            .then((value) => this.setState(() {}));
      }
    };

    Widget buildBody = Container(
      child: ListenableProvider.value(
        value: user,
        child: Consumer<UserProvider>(builder: (context, value, child) {
          return Container(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormRevo(
                      txtController: controllerName,
                      label:
                          '${AppLocalizations.of(context)!.translate('first_name')}*'),
                  FormRevo(
                      txtController: controllerSurname,
                      label:
                          '${AppLocalizations.of(context)!.translate('last_name')}*'),
                  FormRevo(
                      txtController: controllerCompany,
                      label:
                          '${AppLocalizations.of(context)!.translate('comp_name')}'),
                  FormRevo(
                      txtController: controllerAddress,
                      label:
                          '${AppLocalizations.of(context)!.translate('street')}*'),
                  FormRevo(
                    txtController: controllerAddressOpt,
                    label: '${AppLocalizations.of(context)!.translate('placeholder_address')}',
                    hint: '${AppLocalizations.of(context)!.translate('placeholder_address')}',
                  ),
                  FormRevo(
                      txtController: controllerTown,
                      label:
                          '${AppLocalizations.of(context)!.translate('town')}*'),
                  _buildDropdown(
                      '${AppLocalizations.of(context)!.translate('country')}*',
                      value,
                      'countries'),
                  value.selectedCountries == null
                      ? Container()
                      : value.selectedCountries!.states!.isEmpty
                          ? FormRevo(
                              txtController: controllerState,
                              label:
                                  '${AppLocalizations.of(context)!.translate('state')}*',
                            )
                          : _buildDropdown(
                              '${AppLocalizations.of(context)!.translate('state')}*',
                              value,
                              'states'),
                  FormRevo(
                      txtController: controllerPostCode,
                      label:
                          '${AppLocalizations.of(context)!.translate('postcode')}*'),
                  Visibility(
                      visible: widget.title!.toLowerCase() == 'billing',
                      child: Column(
                        children: [
                          FormRevo(
                              txtController: controllerPhone,
                              label:
                                  '${AppLocalizations.of(context)!.translate('phone')}*'),
                          FormRevo(
                              txtController: controllerEmail,
                              label:
                                  '${AppLocalizations.of(context)!.translate('email_address')}*'),
                        ],
                      )),
                  Container(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          backgroundColor:
                              value.loading ? Colors.grey : secondaryColor),
                      onPressed: value.loading ? null : save,
                      child: value.loading
                          ? customLoading()
                          : Text(
                              AppLocalizations.of(context)!.translate('save')!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: responsiveFont(10),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          title: Text('${AppLocalizations.of(context)!.translate('my_address')}',
            style:
                TextStyle(fontSize: responsiveFont(16), color: secondaryColor),
          ),
        ),
        body: buildBody);
  }

  _buildDropdown(String? label, UserProvider? value, String? type) {
    var _value;
    if (value != null) {
      if (type == 'countries' && value.selectedCountries != null) {
        _value = value.selectedCountries!.code;
      } else if (type == 'states' && value.selectedStates != null) {
        _value = value.selectedStates!.code;
      }
    }
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: responsiveFont(8),
                color: Colors.black54),
          ),
          Container(
            child: DropdownButton(
              isExpanded: true,
              underline: Container(
                height: 1.0,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFBDBDBD),
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              hint: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("Choose $label")),
              value: _value,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: type == 'countries'
                  ? value!.countries!.map((CountriesModel items) {
                      return DropdownMenuItem(
                          value: items.code,
                          child: Container(
                            child: Text(
                              items.name!,
                              style: TextStyle(
                                  color: _value != items.code
                                      ? Colors.black45
                                      : null),
                            ),
                          ));
                    }).toList()
                  : value!.selectedCountries!.states!.map((States items) {
                      return DropdownMenuItem(
                          value: items.code,
                          child: Container(
                            child: Text(
                              items.name!,
                              style: TextStyle(
                                  color: _value != items.code
                                      ? Colors.black45
                                      : null),
                            ),
                          ));
                    }).toList(),
              onChanged: (value) {
                if (type == 'countries') {
                  context.read<UserProvider>().setCountries(value.toString());
                  setState(() {
                    country = value.toString();
                    controllerState.clear();
                  });
                } else {
                  context.read<UserProvider>().setStates(value.toString());
                  setState(() {
                    controllerState.text = value.toString();
                  });
                }
              },
            ),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
