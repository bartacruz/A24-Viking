var check_magnetos = func {
    var magnetos = 0;
    if (getprop("/controls/engines/engine/ignition0")) magnetos += 1;
    if (getprop("/controls/engines/engine/ignition1")) magnetos += 2;
    setprop("/controls/engines/engine[0]/magnetos", magnetos);
};
setlistener("/controls/engines/engine/ignition0",check_magnetos,0,1);
setlistener("/controls/engines/engine/ignition1",check_magnetos,0,1);