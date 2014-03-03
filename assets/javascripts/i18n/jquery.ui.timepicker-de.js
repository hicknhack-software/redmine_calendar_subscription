jQuery(function($){
  $.timepicker.regional['de'] = {
    timeOnlyTitle: 'Zeit wählen',
    timeText: 'Uhrzeit',
    hourText: 'Stunde',
    minuteText: 'Minute',
    secondText: 'Sekunde',
    millisecText: 'Millisek.',
    timezoneText: 'Zeitzone',
    currentText: 'Jetzt',
    closeText: 'Schließen',
    isRTL: false
  };
  $.timepicker.setDefaults($.timepicker.regional['de']);
});
