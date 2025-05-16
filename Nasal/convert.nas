#############################################################################
#### Helijah                                                     08-2020 ####
####                                                             03-2021 ####
####                                                             03-2022 ####
####                                                             08-2022 ####
####                                                             09-2022 ####
#### Quelques propriétés utiles                                          ####
#############################################################################

var convert = func {
  ###########################################################################
  var rpm0 = getprop("/engines/engine[0]/rpm");
  if ( ! rpm0 ) {
    rpm0 = 0;
  }
  var prop_rpm0 = getprop("/engines/engine[0]/prop-rpm");
  if ( ! rpm0 ) {
    rpm0 = 0;
  }
  var cht0 = getprop("/engines/engine[0]/cht-degC");
  if ( ! cht0 ) {
    cht0 = 0;
  }
  var mp0 = getprop("/engines/engine[0]/mp-osi");
  if (! mp0 ) {
    mp0 = 0;
  }
  var run0 = getprop("/engines/engine[0]/running");
  if (! run0 ) {
    run0 = 0;
  }
  var flow0 = getprop("/engines/engine[0]/fuel-flow-gph");
  if ( ! flow0 ) {
    flow0 = 0;
  }
  var oilt0 = getprop("/engines/engine[0]/oil-temperature");
  if ( ! oilt0 ) {
    oilt0 = 0;
  }
  
  ###########################################################################
  var oat = getprop("/environment/temperature-degc");
  if ( ! oat ) {
    oat = 0;
  }
  var ias = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
  if ( ! ias ) {
    ias = 0;
  }

  var mb0 = getprop("/engines/engine[0]/torque-ftlb");
  if ( ! mb0 ) {
    mb0 = 0;
  }
  
  var fuel_pres0 = 0.0;
  var oil_pres0 = 0.0;
  ###########################################################################

  if ( mp0 < 10) {
     mp0 = 10;
  }
  prop_rpm0 = rpm0 * 0.411;
  #Engine 0
  if (run0) {
    cht0  = cht0 + (mp0 * 8 + oat - ias/3 - cht0) / 250;
    oilt0 = oilt0 +(rpm0 / 25 + oat - oilt0) / 250;
  } else {
    if ( ! cht0  ) {
      cht0 = oat;
    }
    if ( ! oilt0 ) {
      oilt0 = oat;
    }
    cht0 = cht0 + (oat - cht0)/100;
    oilt0 = oilt0 + (oat - oilt0)/100;
  }
  
  #Engine 0
  if (rpm0 > 100.0) {
    fuel_pres0 = rpm0 / 100;
    oil_pres0 = rpm0 / 25;
  }
  setprop("/engines/engine[0]/prop-rpm", prop_rpm0);
  setprop("/engines/engine[0]/oil-pressure-psi", oil_pres0);
  setprop("/engines/engine[0]/fuel-pressure-psi", fuel_pres0);

  setprop("/engines/engine[0]/cht-degC", cht0);
  setprop("/engines/engine[0]/cht-degf", inverseTemp(cht0));
  setprop("/engines/engine[0]/oil-temperature", oilt0);


  ##################################################
  # Torque -> Pourcent by Helijah : Max 4094 -> 100%
  ##################################################
  var torqpourcent = mb0  * 0.0244259892526;
  setprop("/engines/engine[0]/torque-pourcent", torqpourcent);
  var smb = sprintf("%03.f", torqpourcent);

  setprop("/engines/engine[0]/Torque/unit100", chr(smb[0]));
  setprop("/engines/engine[0]/Torque/unit10", chr(smb[1]));
  setprop("/engines/engine[0]/Torque/unit1", chr(smb[2]));

  ##################################################

  setprop("/engines/engine[0]/egt-degC", convertTemp(getprop("/engines/engine[0]/egt-degf")));
  setprop("/engines/engine[0]/oil-temperature-degC", getprop("/engines/engine[0]/oil-temperature"));

  setprop("/engines/engine[0]/itt-norm", getprop("/engines/engine[0]/cht-degC") / 100);
}

var convertTemp = func(degF) {
  var degC = 0;
  if ( degF != nil ) {
    #print(degF);
    degC = (degF - 32) * 5/9;
  }
  return degC;
}
var inverseTemp = func(degC) {
  var degF = 0;
  if ( degC != nil ) {
    degF = (degC * 5/9) + 32 ;
  }
  return degF;
}

###  Main loop ###
var update_convert = func {
  convert();
  settimer(update_convert, 0);
}
setlistener("/sim/signals/fdm-initialized", update_convert);
