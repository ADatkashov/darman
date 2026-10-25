import 'package:flutter/material.dart';

IconData categoryIcon(String icon) => switch (icon) {
  'pain' => Icons.healing_outlined,
  'cold' => Icons.thermostat_outlined,
  'vitamins' => Icons.spa_outlined,
  'digestive' => Icons.restaurant_outlined,
  'first_aid' => Icons.medical_services_outlined,
  'skin' => Icons.face_retouching_natural_outlined,
  'baby' => Icons.child_friendly_outlined,
  'personal' => Icons.clean_hands_outlined,
  'devices' => Icons.monitor_heart_outlined,
  'rx' => Icons.description_outlined,
  _ => Icons.medication_outlined,
};
