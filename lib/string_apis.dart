import 'package:flutter/material.dart';

///extension <extension name>? on <type> {
///   (<member definition>)*
/// }



  extension TimeParse on String {

  String toTimeParse (){
    int hour = DateTime.parse(this).hour;
    String hours = hour>12 ? "${hour - 12}" : "${hour}";
    String a = hour >= 12 ? "PM" : "AM";
    String minute = DateTime.parse(this).minute <10
        ?"0${DateTime.parse(this).minute.toString()}"
        :DateTime.parse(this).minute.toString();
    String day = DateTime.parse(this).day.toString();
    String month = DateTime.parse(this).month.toString();
    String year = DateTime.parse(this).year.toString();
    return " $hours:$minute  $a \n$day/$month/$year ";
  }
  }

//Implementing generic extensions
///extension MyFancyList<T> on List<T> {
///   int get doubleLength => length * 2;
///   List<T> operator -() => reversed.toList();
///   List<List<T>> split(int at) => [sublist(0, at), sublist(at)];
/// }