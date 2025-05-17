# Shorthand
var e = electric;

# Create new electric system that updates 10 times a second.
var electrical = e.System.new("A24",0.1);

### Starter and Main Bus
var starter_bus = e.Bus.new("starter-bus");
var main_bus = e.Bus.new("main-bus");

# Battery (12v 18a/h 200 CCA as per POH)
# connected to the starter bus to feed the starter directly.
# connected to the main bus from the starter bus via the battery switch.
# 
var battery = e.Battery.new("battery",12,18.0,cc_amps=200.0,charge_amps=3.0);
var battery_switch = e.Switch.new("battery-switch","/controls/electric/battery-switch");
var master_switch = e.Switch.new("master-switch","/controls/electric/master-switch");
electrical.connect(battery, battery_switch, starter_bus, master_switch, main_bus);

# Reverse connection for loading the battery...
electrical.connect(starter_bus,battery_switch,battery);

# External source
# Connected directly to the starter bus, but we add a switch to obey the property
var external_source = e.Alternator.new("external",false,14.0,100.0);
electrical.connect(external_source,e.Switch.new("external-power","/controls/electric/external-power"),starter_bus);

var alternator = e.Alternator.new("alternator","/engines/engine[0]/rpm",14.0,50.0,1400);
electrical.connect(alternator,e.Switch.new("alt-switch","/controls/electric/alt-switch"),starter_bus);

### Engine related loads

# Starter engine draws 50A while cranking.
electrical.connect(starter_bus,e.Load.new("starter",50.0,"/controls/switches/starter"));

# Two 1A Fuel pumps with a common 3A breaker (as per POH).
var fuel_breaker = e.Breaker.new("fuel-pump",3.0);
electrical.connect(main_bus,fuel_breaker);
electrical.connect(fuel_breaker,e.Load.new("fuel-pump1",1.0,"/controls/engines/engine[0]/fuel-pump[0]"));
electrical.connect(fuel_breaker,e.Load.new("fuel-pump2",1.0,"/controls/engines/engine[0]/fuel-pump[1]"));

### Exterior Lights

# Common 15A breaker (as per POH) connected to main bus
var el_braker = e.Breaker.new("exterior-lights",15.0);
electrical.connect(main_bus,el_braker);

# landing light 150w @12v = 12.5A
electrical.connect(el_braker, e.Light.new("landing-lights",12.5));

# 7w average led strobe light
electrical.connect(el_braker, e.Light.new("strobe-lights",0.58));

# 2x 10w led nav lights
electrical.connect(el_braker, e.Light.new("nav-lights",1.6));

### Interior Lights

# Instrument lights (led, 7w total at full power)
electrical.connect(main_bus,e.Light.new("annunciators",0.58,"/controls/electric/master-switch"));
electrical.connect(main_bus,e.Light.new("instrument-lights[0]",0.58));

### Avionics

var avionics_switch = e.Switch.new("master-avionics","/controls/electric/avionics-switch" );
var avionics_bus = e.Bus.new("avionics-bus");
electrical.connect(main_bus,avionics_switch,avionics_bus);
electrical.connect(avionics_bus, e.Load.new("turn-coordinator",1.0,"/controls/electric/avionics-switch"));
electrical.connect(avionics_bus, e.Load.new("gps",0.2,"/controls/electric/avionics-switch"));
electrical.connect(avionics_bus, e.Load.new("eis",0.2,"/controls/electric/avionics-switch"));
var radio_breaker = electrical.connect(avionics_bus, e.Breaker.new("radio",7.5));

electrical.add_instrument(radio_breaker, "comm[0]",0.5);
electrical.add_instrument(radio_breaker, "nav[0]",0.5);
electrical.add_instrument(radio_breaker,"transponder",3.0);

setlistener("sim/signals/fdm-initialized",func{
        electrical.enable();
    } 
);
print("A24 electrical system loaded");

