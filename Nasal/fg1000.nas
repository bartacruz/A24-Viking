var nasal_dir = getprop("/sim/fg-root") ~ "/Aircraft/Instruments-3d/FG1000/Nasal/";
var aircraft_dir = getprop("/sim/aircraft-dir");
io.load_nasal(nasal_dir ~ 'FG1000.nas', "fg1000");
io.load_nasal(aircraft_dir ~ '/Nasal/A24-InterfaceController.nas', "fg1000");  # use custom controller

var interfaceController = fg1000.GenericInterfaceController.getOrCreateInstance();
interfaceController.start();
io.load_nasal(aircraft_dir ~ '/Nasal/EIS/EIS-A24.nas', "fg1000");
io.load_nasal(aircraft_dir ~ '/Nasal/EIS/EISController.nas', "fg1000");
io.load_nasal(aircraft_dir ~ '/Nasal/EIS/EISStyles.nas', "fg1000");
io.load_nasal(aircraft_dir ~ '/Nasal/EIS/EISOptions.nas', "fg1000");


# Create the FG1000
var EIS_Class = fg1000.EIS;

var fg1000system = fg1000.FG1000.getOrCreateInstance(EIS_Class:EIS_Class, EIS_SVG: "Nasal/EIS/MFDPages/EIS-A24.svg");

# Create a PFD as device 1, MFD as device 2
fg1000system.addMFD(1);
# Display the devices
fg1000system.display(1);
var fg1000_power = func(){
    if (getprop("systems/electrical/outputs/gps")){
        fg1000system.show(1);
    }  else {
        fg1000system.hide(1);
    }
};
setlistener("systems/electrical/outputs/gps", fg1000_power);