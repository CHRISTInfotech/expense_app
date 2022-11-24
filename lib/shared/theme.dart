import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const kLightPrimary = Color(0xFF34CCFD);  ///HOME
const kPrimary = Color(0xFF5CA6FD);
const kDarkPrimary = Color(0xFF768CFC);   ///WALLET

const kLightSecondary = Color(0xFF8B70FD);///STATISTICS
const kSecondary = Color(0xFFA054FE);
const kDarkSecondary = Color(0xFFB333FA); ///PROFILE

const kLightNeutral = Color(0xFFF8F8FF);
const kNeutral = Color(0xFFF1F1F1);
const kDarkNeutral = Color(0xFFE8E8E8);

const kBackground = Colors.white;

class FormInput extends StatelessWidget {

  final String hintText;
  final String? initialVal;
  final Color color;
  final   FormFieldValidator<String>? valHandler;
 final void Function(String?)? changeHandler;
  final TextInputType? inputType;
  final List<TextInputFormatter> ?inputFormatter;
  
  const FormInput({
    required this.hintText, 
    required this.color,
    this.initialVal,
      this.valHandler,
      this.changeHandler,
    this.inputType,
    this.inputFormatter
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      child: TextFormField(
        initialValue: initialVal,
        keyboardType: inputType,
        inputFormatters: inputFormatter,
        validator: valHandler,
        onChanged: changeHandler,
        decoration: InputDecoration( 
          hintText: hintText, hintStyle: TextStyle(color:Colors.grey[500] ),
          border: InputBorder.none,
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: color, width: 2.0)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.0)),
          errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 2.0)),
          focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.0)),
        ),
      ),
    );
  }
}

class FullButton extends StatelessWidget {

  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback handler;
  
  const FullButton({
    required this.icon, 
    required this.text, 
    required this.color,
    required this.handler
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: handler,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: color
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Visibility(
              child: Icon(icon, color: Colors.white,),
              visible: (icon == null) ? false : true,
            ),
            SizedBox(width: 10,),
            Text( text,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 20
              ),
            ),
          ],
        )
      ),
    );
  }
}

class AdaptiveFlatButton extends StatelessWidget {
  final String text;
  final VoidCallback handler;
  final Color color;

  AdaptiveFlatButton(this.text, this.handler, this.color);

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
    ? CupertinoButton(
      child: Text( text,
        style: TextStyle( fontWeight: FontWeight.bold ),
      ),
      onPressed: handler,
    )
    : TextButton(
      // color: color,
      child: Text( text,
        style: TextStyle( fontWeight: FontWeight.bold ),
      ),
      onPressed: handler,
    );
  }
}

Widget dialog(
  String title,
  String content,
  List<Widget> actions,
  { Color? titleColor }
) => AlertDialog(
  shape: RoundedRectangleBorder( borderRadius: BorderRadius.all(Radius.circular(20.0)) ),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
  title: Text(title, 
    textAlign: TextAlign.center, 
    style: TextStyle(color: titleColor ?? Colors.black, fontWeight: FontWeight.bold),
  ),
  content: Text(content, textAlign: TextAlign.start),
  actions: actions,
);

final kFieldDecoration = InputDecoration(
  border: InputBorder.none,
  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xffbec2c3), width: 2.0)),
  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.0)),
  errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 2.0)),
  focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.0)),
);

class MaskedTextInputFormatter extends TextInputFormatter {
  final String mask;
  final String separator;

  MaskedTextInputFormatter({
    required this.mask,
    required this.separator,
  }) { assert(mask != null); assert (separator != null); }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    
    if(newValue.text.length > 0) {
      if(newValue.text.length > oldValue.text.length) {
        if(newValue.text.length > mask.length) return oldValue;
        if(newValue.text.length < mask.length && mask[newValue.text.length - 1] == separator) {
          return TextEditingValue(
            text: '${oldValue.text}$separator${newValue.text.substring(newValue.text.length-1)}'.replaceAll("[^0-9]", ""),
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        }
      }
    }
    return newValue;
  }
}

