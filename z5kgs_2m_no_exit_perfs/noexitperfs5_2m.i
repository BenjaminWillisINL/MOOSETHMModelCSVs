T_in = 298.15         # K
m_dot_in = 5.0     # kg/s
p_bottom = 25.1865e6 #
p_top = 101325      # Pa
mu = 1e-4           # Pa*s
rho = 1000          #kg/m^3
#pi = 3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679821480865132823066470938446095

# pipe parameters
pipe_dia = 0.18
pipe_dia2 = 0.09525 # Multiplied by 10 because 10 perforations are used
pipe_dia3 = 2

A_frac = ${fparse pi*pipe_dia3 *pipe_dia3/4}


closures = my_closures



n_elems = 200

# For Pipe Flow
n_part_elems_well = '5 5 50'
hs_names = 'wall cement rock'
hs_widths = '0.00635 5.10E-02 49.9426500'
hs_materials = 'mild_steel cement rock'

flow_blocks = 'injection_pipe pipe2 fracture1_perf1 fracture1 fracture1_perf2 pipe3 fracture2_perf1 fracture2 fracture2_perf2 pipe4 fracture3 pipe5 pipe5 pipe6 pipe7 production_pipe'



# For Fractures
hs_names3 = 'rock'
hs_widths3 = '50'
hs_materials3 = 'rock'
n_part_elems_well3 = '50'

[GlobalParams]
  initial_p = initial_p_fn
  initial_vel = 0
  initial_T = initial_T_fn
  initial_vel_x = 0
  initial_vel_y = 0
  initial_vel_z = 0
  gravity_vector = '0 0 -9.81'

  rdg_slope_reconstruction = full
  #Hw = 25000
  closures = my_closures
  fp = water

  #scaling_factor_1phase = '1 1e-3 1e-8'
  #scaling_factor_rhoV = 1
  #scaling_factor_rhouV = 1e-3
  #scaling_factor_rhovV = 1e-3
  #scaling_factor_rhowV = 1e-3
  #scaling_factor_rhoEV = 1e-8
  #scaling_factor_temperature = 1e-4

[]



[Modules/FluidProperties]
  #[water]
  #  type = SimpleFluidProperties

  #[]
  [water]
    type = StiffenedGasFluidProperties
    gamma = 2.35
    cv = 1816.0
    q = -1.167e6
    p_inf = 1.0e9
    mu = ${mu}
    q_prime = 0
  []
[]

[Closures]
  [my_closures]
    type = Closures1PhaseNone
  []
[]



[HeatStructureMaterials]
  [./mild_steel]
    type = SolidMaterialProperties
    rho = 7850
    cp = 510.8
    k = 60
  [../]

  [./cement]
    type = SolidMaterialProperties
    rho = 2400
    cp = 920
    k = 0.29
  [../]

  [./rock]
    type = SolidMaterialProperties
    rho = 2750
    cp = 830
    k = 3
  [../]
[]

[Functions]
  [./initial_T_fn]
    type = PiecewiseLinear
    axis = z
    xy_data = '
      -2800 469.15
          0 298.15'
  [../]

  [./initial_p_fn]
    type = PiecewiseLinear
    axis = z
    xy_data = '
      -2666 ${p_bottom}
          0 ${p_top}'
  [../]

  # [./p_out_fn]
  #   type = PiecewiseLinear
  #   xy_data = '
  #     0.00E+00 ${p_bottom}
  #     1.02E+06 28e6
  #     3.97E+06 31e6
  #     1.04E+07 32e6
  #     3.01E+07 33e6
  #     5.00E+07 33.5e6'
  # [../]

  [./T_ext_fn]
    type = PiecewiseLinear
    axis = z
    xy_data = '
      -2800 469.15
          0 298.15'
  [../]
  [pressure_set]
    type = ConstantFunction
    value = 2e+6
  []
[]

[AuxVariables]
  [./T_ext]
  [../]
[]

[ICs]
  [./T_ext_ic]
    type = FunctionIC
    variable = T_ext
    function = T_ext_fn
  [../]
[]

[Materials]


  #[Hw_mat]
  #  type = ADWallHeatTransferCoefficient3EqnDittusBoelterMaterial
  #  block = ${flow_blocks}
  #  D_h = D_h
  #  rho = rho
  #  vel = vel
  #  T = T
  #  T_wall = T_wall
  #  cp = cp
  #  mu = ${mu}
  #  k = k
  #[]
  [Hw_mat]
    block = ${flow_blocks}
    type = ADConstantMaterial
    property_name = 'Hw'
    value = 2000
  []

  [f_mat]
    type = ADWallFrictionFunctionMaterial
    block = ${flow_blocks}
    f_D = f_D
    function = 0.0167
    arhoA = rhoA
    arhouA = rhouA
    arhoEA = rhoEA

  []
  #[f_mat]
  #  type = ADWallFrictionChurchillMaterial
  #  block = ${flow_blocks}
  #  D_h = D_h
  #  f_D = f_D
  #  mu = mu
  #  rho = rho
  #  vel = vel
  #[]
[]

[Components]
  [injection_pipe]
    type = FlowChannel1Phase
    position = '0 0 0'
    orientation = '0 0 -2057'
    length = 2057
    n_elems = ${n_elems}
    A = ${fparse pi * pipe_dia * pipe_dia / 4.}
    D_h = ${pipe_dia}
    #roughness = 1e-5
  []

  [HS_injection_pipe]
    type = HeatStructureCylindrical
    position = '0 0 0'
    orientation = ' 0 0 -2057'
    length = 2057
    names = ${hs_names}
    widths = ${hs_widths}
    materials = ${hs_materials}
    n_part_elems = ${n_part_elems_well}
    inner_radius = ${fparse pipe_dia/2}
    n_elems = ${n_elems}
  []

  [HT_injection_pipe]
    type = HeatTransferFromHeatStructure1Phase
    flow_channel = injection_pipe
    hs = HS_injection_pipe
    hs_side = INNER
    P_hf = ${fparse 2 * pi * (pipe_dia/2)}
  []

  [T_injection_pipe]
    type = HSBoundaryExternalAppTemperature
    hs = HS_injection_pipe
    boundary = HS_injection_pipe:outer
    T_ext = T_ext
    #Hw = 25000
  []


  [inlet]
    type = InletMassFlowRateTemperature1Phase
    input = 'injection_pipe:in'
    T = ${T_in}
    m_dot = ${m_dot_in}
    #reversible = false
  []

  [jct1]
    type = VolumeJunction1Phase
    position = '2.5191e-13 0 -2057'
    connections = 'injection_pipe:out pipe2:in'
    volume = ${fparse 0.0001 * pi * pipe_dia * pipe_dia / 4.}
  []



  [pipe2]
    type = FlowChannel1Phase
    position = '2.5191e-13 0 -2057'
    orientation = '1219.99999999999974809 0 -625'
    length = 1030.624
    n_elems = ${n_elems}
    A = ${fparse pi * pipe_dia * pipe_dia / 4.}
    D_h = ${pipe_dia}
    #roughness = 1e-5
  []

  [HS_pipe2]
    type = HeatStructureCylindrical
    position = '2.5191e-13 0 -2057'
    orientation = '1219.99999999999974809 0 -625'
    length = 1030.624
    names = ${hs_names}
    widths = ${hs_widths}
    materials = ${hs_materials}
    n_part_elems = ${n_part_elems_well}
    inner_radius = ${fparse pipe_dia/2}
    n_elems = ${n_elems}
  []

  [HT_pipe2]
    type = HeatTransferFromHeatStructure1Phase
    flow_channel = pipe2
    hs = HS_pipe2
    hs_side = INNER
    P_hf = ${fparse 2 * pi * (pipe_dia/2)}
  []

  [T_pipe2]
    type = HSBoundaryExternalAppTemperature
    hs = HS_pipe2
    boundary = HS_pipe2:outer
    T_ext = T_ext
    #Hw = 25000
  []

  [jct2]
    type = VolumeJunction1Phase
    position = '917.2628469944179905237284145455130972923168953946769672922514350400815052032321574658006540686632290474425835111147119320437630922 0 -2526.909245386484594269195298688753957508758813365313557859909689964089591181860735467159281488075729251431323242298074332452450738'
    connections = 'pipe2:out pipe3:in fracture1_perf1:in'
    volume = ${fparse 0.0001 * pi * pipe_dia * pipe_dia / 4.}
  []


  [fracture1_perf1]
    type = FlowChannel1Phase
    position = '917.2628469944179905237284145455130972923168953946769672922514350400815052032321574658006540686632290474425835111147119320437630922 0 -2526.909245386484594269195298688753957508758813365313557859909689964089591181860735467159281488075729251431323242298074332452450738'
    orientation = '0.1225383909720094762715854544869027076831046053230327077485649599184947967678425341993459313367709525574164888852880679562369078 0 100.064400541684594269195298688753957508758813365313557859909689964089591181860735467159281488075729251431323242298074332452450738'
    length = 1
    n_elems = ${n_elems}
    A = ${fparse pi * pipe_dia2 * pipe_dia2 / 4.}
    D_h = ${pipe_dia2}
    #roughness = 1e-5
  []


  [jct_fracture1_perf1]
    type = VolumeJunction1Phase
    position = '917.2640715887635062834115530595287571423114269995985565389745578363781123295742702131049701012118303296315318327300212436365165211 0 -2525.909246136300530915750627247711166403549964920278722743402239864263751285450154055487598036978552800096569157090603612969180998'
    connections = 'fracture1_perf1:out fracture1:in'
    volume = ${fparse 0.0001 * pi * pipe_dia3 * pipe_dia3 / 4.}
  []

  [fracture1]
    type = FlowChannel1Phase
    position = '917.2640715887635062834115530595287571423114269995985565389745578363781123295742702131049701012118303296315318327300212436365165211 0 -2525.909246136300530915750627247711166403549964920278722743402239864263751285450154055487598036978552800096569157090603612969180998'
    orientation = '0.1225383909720094762715854544869027076831046053230327077485649599184947967678425341993459313367709525574164888852880679562369078 0 100.064400541684594269195298688753957508758813365313557859909689964089591181860735467159281488075729251431323242298074332452450738'
    length = 98.06447557162307005210248929005225739881232750283853044679409922670562628737052780066190947088625665447598227063665130067648666298
    n_elems = ${n_elems}
    A = ${fparse pi * pipe_dia3 * pipe_dia3 / 4.}
    D_h = ${pipe_dia3}
    #roughness = 1e-5
  []
  [HS_fracture1]
    type = HeatStructureCylindrical
    position = '917.2640715887635062834115530595287571423114269995985565389745578363781123295742702131049701012118303296315318327300212436365165211 0 -2525.909246136300530915750627247711166403549964920278722743402239864263751285450154055487598036978552800096569157090603612969180998'
    orientation = '0.1225383909720094762715854544869027076831046053230327077485649599184947967678425341993459313367709525574164888852880679562369078 0 100.064400541684594269195298688753957508758813365313557859909689964089591181860735467159281488075729251431323242298074332452450738'
    length = 98.06447557162307005210248929005225739881232750283853044679409922670562628737052780066190947088625665447598227063665130067648666298
    names = ${hs_names3}
    widths = ${hs_widths3}
    materials = ${hs_materials3}
    n_part_elems = ${n_part_elems_well3}
    inner_radius = ${fparse pipe_dia3/2}
    n_elems = ${n_elems}
  []

  [HT_fracture1]
    type = HeatTransferFromHeatStructure1Phase
    flow_channel = fracture1
    hs = HS_fracture1
    hs_side = INNER
    P_hf = ${fparse 2 * pi * (pipe_dia3/2)}
  []

  [T_fracture1]
    type = HSBoundaryExternalAppTemperature
    hs = HS_fracture1
    boundary = HS_fracture1:outer
    T_ext = T_ext
    #Hw = 25000
  []


  [jct_fracture1_perf2]
    type = VolumeJunction1Phase
    position = '917.3841607910444842403168614859843401500054683950784107532768772037033928736578872526956839674513987178110516783846906884072465711 0 -2427.84484409498406335344467144104279110520884844503483511650745009982583989641058141167168345109717645133475408520747071948326974'
    connections = 'fracture1:out fracture1_perf2:in'
    volume = ${fparse 0.0001 * pi * pipe_dia3 * pipe_dia3 / 4.}
  []

  [fracture1_perf2]
    type = FlowChannel1Phase
    position = '917.3841607910444842403168614859843401500054683950784107532768772037033928736578872526956839674513987178110516783846906884072465711 0 -2427.84484409498406335344467144104279110520884844503483511650745009982583989641058141167168345109717645133475408520747071948326974'
    orientation = '0.1225383909720094762715854544869027076831046053230327077485649599184947967678425341993459313367709525574164888852880679562369078 0 100.064400541684594269195298688753957508758813365313557859909689964089591181860735467159281488075729251431323242298074332452450738'
    length = 1
    n_elems = ${n_elems}
    A = ${fparse pi * pipe_dia3 * pipe_dia3 / 4.}
    D_h = ${pipe_dia3}
    #roughness = 1e-5
  []



  [jct7]
    type = VolumeJunction1Phase
    position = '917.38538538539 0 -2426.8448448448'
    connections = 'pipe6:out fracture1_perf2:out pipe7:in'
    volume = ${fparse 0.0001 * pi * pipe_dia * pipe_dia / 4.}
  []

  [pipe3]
    type = FlowChannel1Phase
    position = '917.2628469944179905237284145455130972923168953946769672922514350400815052032321574658006540686632290474425835111147119320437630922 0 -2526.909245386484594269195298688753957508758813365313557859909689964089591181860735467159281488075729251431323242298074332452450738'
    orientation = '1219.99999999999974809 0 -625'
    length = 134.1119999999997757982699933596327619523117633145552848151914137913993048371005845221926009781946176878406412178418124332829957432
    n_elems = ${n_elems}
    A = ${fparse pi * pipe_dia * pipe_dia / 4.}
    D_h = ${pipe_dia}
    #roughness = 1e-5
  []

  [HS_pipe3]
    type = HeatStructureCylindrical
    position = '917.2628469944179905237284145455130972923168953946769672922514350400815052032321574658006540686632290474425835111147119320437630922 0 -2526.909245386484594269195298688753957508758813365313557859909689964089591181860735467159281488075729251431323242298074332452450738'
    orientation = '1219.99999999999974809 0 -625'
    length = 134.1119999999997757982699933596327619523117633145552848151914137913993048371005845221926009781946176878406412178418124332829957432
    names = ${hs_names}
    widths = ${hs_widths}
    materials = ${hs_materials}
    n_part_elems = ${n_part_elems_well}
    inner_radius = ${fparse pipe_dia/2}
    n_elems = ${n_elems}
  []

  [HT_pipe3]
    type = HeatTransferFromHeatStructure1Phase
    flow_channel = pipe3
    hs = HS_pipe3
    hs_side = INNER
    P_hf = ${fparse 2 * pi * (pipe_dia/2)}
  []

  [T_pipe3]
    type = HSBoundaryExternalAppTemperature
    hs = HS_pipe3
    boundary = HS_pipe3:outer
    T_ext = T_ext
    #Hw = 25000
  []


  [jct3]
    type = VolumeJunction1Phase
    position = '1036.623501254473153353695992567689810142073162932761581504125430266367144607918901712056764268364150987947190195844173158087648307 0 -2588.057121544299880839884822606056650585394581577628555251497900931876080971135686326999209103703554919539146874069777053205958393'
    connections = 'pipe3:out fracture2_perf1:in pipe4:in'
    volume = ${fparse 0.0001 * pi * pipe_dia * pipe_dia / 4.}
  []

  ## TOOK break here Start fixing vectors from here

  [fracture2_perf1]
    type = FlowChannel1Phase
    position = '1036.623501254473153353695992567689810142073162932761581504125430266367144607918901712056764268364150987947190195844173158087648307 0 -2588.057121544299880839884822606056650585394581577628555251497900931876080971135686326999209103703554919539146874069777053205958393'
    orientation = '0.343465712526846646304007432310189857926837067238418495874569733632855392081098287943235731635849012052809804155826841912351693 0 99.900965388099880839884822606056650585394581577628555251497900931876080971135686326999209103703554919539146874069777053205958393'
    length = 1
    n_elems = ${n_elems}
    A = ${fparse pi * pipe_dia2 * pipe_dia2 / 4.}
    D_h = ${pipe_dia2}
    #roughness = 1e-5
  []

  [jct_fracture2_perf1]
    type = VolumeJunction1Phase
    position = '1036.626939296150546154407449105679820299916123611320944397219835889881242544348211203595554565618487396521315082047359428279718699 0 -2587.057127454382633123905626459237936030272054366214222394840134153701923618110508657226030905547389892324123110947853904640256311'
    connections = 'fracture2_perf1:out fracture2:in'
    volume = ${fparse 0.0001 * pi * pipe_dia3 * pipe_dia3 / 4.}
  []

  [fracture2]
    type = FlowChannel1Phase
    position = '1036.626939296150546154407449105679820299916123611320944397219835889881242544348211203595554565618487396521315082047359428279718699 0 -2587.057127454382633123905626459237936030272054366214222394840134153701923618110508657226030905547389892324123110947853904640256311'
    orientation = '0.343465712526846646304007432310189857926837067238418495874569733632855392081098287943235731635849012052809804155826841912351693 0 99.900965388099880839884822606056650585394581577628555251497900931876080971135686326999209103703554919539146874069777053205958393'
    length = 97.90155581456182682116814463820372338064703154335045984390718274800565840279098911916336721242085105005555949462757708549479806153
    n_elems = ${n_elems}
    A = ${fparse pi * pipe_dia3 * pipe_dia3 / 4.}
    D_h = ${pipe_dia3}
    #roughness = 1e-5
  []

  [HS_fracture2]
    type = HeatStructureCylindrical
    position = '1036.626939296150546154407449105679820299916123611320944397219835889881242544348211203595554565618487396521315082047359428279718699 0 -2587.057127454382633123905626459237936030272054366214222394840134153701923618110508657226030905547389892324123110947853904640256311'
    orientation = '0.343465712526846646304007432310189857926837067238418495874569733632855392081098287943235731635849012052809804155826841912351693 0 99.900965388099880839884822606056650585394581577628555251497900931876080971135686326999209103703554919539146874069777053205958393'
    length = 97.90155581456182682116814463820372338064703154335045984390718274800565840279098911916336721242085105005555949462757708549479806153
    names = ${hs_names3}
    widths = ${hs_widths3}
    materials = ${hs_materials3}
    n_part_elems = ${n_part_elems_well3}
    inner_radius = ${fparse pipe_dia3/2}
    n_elems = ${n_elems}
  []

  [HT_fracture2]
    type = HeatTransferFromHeatStructure1Phase
    flow_channel = fracture2
    hs = HS_fracture2
    hs_side = INNER
    P_hf = ${fparse 2 * pi * (pipe_dia3/2)}
  []

  [T_fracture2]
    type = HSBoundaryExternalAppTemperature
    hs = HS_fracture2
    boundary = HS_fracture2:outer
    T_ext = T_ext
    #Hw = 25000
  []

  [jct_fracture2_perf2]
    type = VolumeJunction1Phase
    position = '1036.963528925322607199288543462009989842157039321440637106905594376485902063570690508461209702745663591425875113796813729807929608 0 -2489.156150246117247715979196146818714555122527211414332856657766778174157353025177669773178198156165027215023763121923148565702082'
    connections = 'fracture2_perf2:in fracture2:out'
    volume = ${fparse 0.0001 * pi * pipe_dia3 * pipe_dia3 / 4.}
  []

  [fracture2_perf2]
    type = FlowChannel1Phase
    position = '1036.963528925322607199288543462009989842157039321440637106905594376485902063570690508461209702745663591425875113796813729807929608 0 -2489.156150246117247715979196146818714555122527211414332856657766778174157353025177669773178198156165027215023763121923148565702082'
    orientation = '0.343465712526846646304007432310189857926837067238418495874569733632855392081098287943235731635849012052809804155826841912351693 0 99.900965388099880839884822606056650585394581577628555251497900931876080971135686326999209103703554919539146874069777053205958393'
    length = 1
    n_elems = ${n_elems}
    A = ${fparse pi * pipe_dia3 * pipe_dia3 / 4.}
    D_h = ${pipe_dia3}
    #roughness = 1e-5
  []

  [jct6]
    type = VolumeJunction1Phase
    position = '1036.96696696700 0 -2488.15615615620'
    connections = 'fracture2_perf2:out pipe5:out pipe6:in'
    volume = ${fparse 0.0001 * pi * pipe_dia * pipe_dia / 4.}
  []

  [pipe4]
    type = FlowChannel1Phase
    position = '1036.623501254473153353695992567689810142073162932761581504125430266367144607918901712056764268364150987947190195844173158087648307 0 -2588.057121544299880839884822606056650585394581577628555251497900931876080971135686326999209103703554919539146874069777053205958393'
    orientation = '1219.99999999999974809 0 -625'
    length = 96.6216000000002242017300066403672380476882366854447151848085862086006951628994154778073990218053823121593587821581875667170042568
    n_elems = ${n_elems}
    A = ${fparse pi * pipe_dia * pipe_dia / 4.}
    D_h = ${pipe_dia}
    #roughness = 1e-5
  []

  [HS_pipe4]
    type = HeatStructureCylindrical
    position = '1036.623501254473153353695992567689810142073162932761581504125430266367144607918901712056764268364150987947190195844173158087648307 0 -2588.057121544299880839884822606056650585394581577628555251497900931876080971135686326999209103703554919539146874069777053205958393'
    orientation = '1219.99999999999974809 0 -625'
    length = 96.6216000000002242017300066403672380476882366854447151848085862086006951628994154778073990218053823121593587821581875667170042568
    names = ${hs_names}
    widths = ${hs_widths}
    materials = ${hs_materials}
    n_part_elems = ${n_part_elems_well}
    inner_radius = ${fparse pipe_dia/2}
    n_elems = ${n_elems}
  []

  [HT_pipe4]
    type = HeatTransferFromHeatStructure1Phase
    flow_channel = pipe4
    hs = HS_pipe4
    hs_side = INNER
    P_hf = ${fparse 2 * pi * (pipe_dia/2)}
  []

  [T_pipe4]
    type = HSBoundaryExternalAppTemperature
    hs = HS_pipe4
    boundary = HS_pipe4:outer
    T_ext = T_ext
    #Hw = 25000
  []


  [jct4]
    type = VolumeJunction1Phase
    position = '1122.617427164558731241613786393149188176286014106565826646572729158866647577956995606874692005341674875432830107018885414872149641 0 -2632.111386867089632706818100151039030971087186774463879984164898425809558645248102213100492481793422376467688447104782164156139538'
    connections = 'pipe4:out fracture3:in'
    volume = ${fparse 0.0001 * pi * pipe_dia3 * pipe_dia3 / 4.}
  []

  [fracture3]
    type = FlowChannel1Phase
    position = '1122.617427164558731241613786393149188176286014106565826646572729158866647577956995606874692005341674875432830107018885414872149641 0 -2632.111386867089632706818100151039030971087186774463879984164898425809558645248102213100492481793422376467688447104782164156139538'
    orientation = '-0.235044782158731241613786393149188176286014106565826646572729158866647577956995606874692005341674875432830107018885414872149641 0 100.161436917189632706818100151039030971087186774463879984164898425809558645248102213100492481793422376467688447104782164156139538'
    length = 100.1617127018392107082677912904102391759840600506092245079207843746364902370741653573756231075282759892565263907571110035070651488
    n_elems = ${n_elems}
    A = ${fparse pi * pipe_dia3 * pipe_dia3 / 4.}
    D_h = ${pipe_dia3}
    #roughness = 1e-5
  []

  [HS_fracture3]
    type = HeatStructureCylindrical
    position = '1122.617427164558731241613786393149188176286014106565826646572729158866647577956995606874692005341674875432830107018885414872149641 0 -2632.111386867089632706818100151039030971087186774463879984164898425809558645248102213100492481793422376467688447104782164156139538'
    orientation = '-0.235044782158731241613786393149188176286014106565826646572729158866647577956995606874692005341674875432830107018885414872149641 0 100.161436917189632706818100151039030971087186774463879984164898425809558645248102213100492481793422376467688447104782164156139538'
    length = 100.1617127018392107082677912904102391759840600506092245079207843746364902370741653573756231075282759892565263907571110035070651488
    names = ${hs_names3}
    widths = ${hs_widths3}
    materials = ${hs_materials3}
    n_part_elems = ${n_part_elems_well3}
    inner_radius = ${fparse pipe_dia3/2}
    n_elems = ${n_elems}
  []

  [HT_fracture3]
    type = HeatTransferFromHeatStructure1Phase
    flow_channel = fracture3
    hs = HS_fracture3
    hs_side = INNER
    P_hf = ${fparse 2 * pi * (pipe_dia3/2)}
  []

  [T_fracture3]
    type = HSBoundaryExternalAppTemperature
    hs = HS_fracture3
    boundary = HS_fracture3:outer
    T_ext = T_ext
    #Hw = 25000
  []

  [jct5]
    type = VolumeJunction1Phase
    position = '1122.3823823824 0 -2531.9499499499'
    connections = 'fracture3:out pipe5:in'
    volume = ${fparse 0.0001 * pi * pipe_dia3 * pipe_dia3 / 4.}
  []

  [pipe5]
    type = FlowChannel1Phase
    position = '1122.3823823824 0 -2531.9499499499'
    orientation = '-1219 0 625'
    length = 95.98796573232744884430750078506290102503278647382158534085570989394969673954105727357396694128582740674997664529042836849765532463
    n_elems = ${n_elems}
    A = ${fparse pi * pipe_dia * pipe_dia / 4.}
    D_h = ${pipe_dia}
    #roughness = 1e-5
  []

  [T_pipe5]
    type = HSBoundaryExternalAppTemperature
    hs = HS_pipe5
    boundary = HS_pipe5:outer
    T_ext = T_ext
    #Hw = 25000
  []

  [HS_pipe5]
    type = HeatStructureCylindrical
    position = '1122.3823823824 0 -2531.9499499499'
    orientation = '-1219 0 625'
    length = 95.98796573232744884430750078506290102503278647382158534085570989394969673954105727357396694128582740674997664529042836849765532463
    names = ${hs_names}
    widths = ${hs_widths}
    materials = ${hs_materials}
    n_part_elems = ${n_part_elems_well}
    inner_radius = ${fparse pipe_dia/2}
    n_elems = ${n_elems}
  []

  [HT_pipe5]
    type = HeatTransferFromHeatStructure1Phase
    flow_channel = pipe5
    hs = HS_pipe5
    hs_side = INNER
    P_hf = ${fparse 2 * pi * (pipe_dia/2)}
  []

  [pipe6]
    type = FlowChannel1Phase
    position = '1036.96696696700 0 -2488.15615615620'
    orientation = '-1219 0 625'
    length = 134.3831520254032945149806604022249511373686265222140310267294357738408632051396721890210394615420535395791672387625071589120847354
    n_elems = ${n_elems}
    A = ${fparse pi * pipe_dia * pipe_dia / 4.}
    D_h = ${pipe_dia}
    roughness = 1e-5
  []

  [HS_pipe6]
    type = HeatStructureCylindrical
    position = '1036.96696696700 0 -2488.15615615620'
    orientation = '-1219 0 625'
    length = 134.3831520254032945149806604022249511373686265222140310267294357738408632051396721890210394615420535395791672387625071589120847354
    names = ${hs_names}
    widths = ${hs_widths}
    materials = ${hs_materials}
    n_part_elems = ${n_part_elems_well}
    inner_radius = ${fparse pipe_dia/2}
    n_elems = ${n_elems}
  []

  [HT_pipe6]
    type = HeatTransferFromHeatStructure1Phase
    flow_channel = pipe6
    hs = HS_pipe6
    hs_side = INNER
    P_hf = ${fparse 2 * pi * (pipe_dia/2)}
  []

  [T_pipe6]
    type = HSBoundaryExternalAppTemperature
    hs = HS_pipe6
    boundary = HS_pipe6:outer
    T_ext = T_ext
    #Hw = 25000
  []


  [pipe7]
    type = FlowChannel1Phase
    position = '917.385385385390 0 -2426.844844844800'
    orientation = '-1219 0 625'
    length = 1029.8137466431315497906037378549111856734274905914330325658709398128891119815951012845583455723940079060997436706937542731921405
    n_elems = ${n_elems}
    A = ${fparse pi * pipe_dia * pipe_dia / 4.}
    D_h = ${pipe_dia}
    roughness = 1e-5
  []

  [HS_pipe7]
    type = HeatStructureCylindrical
    position = '917.385385385390 0 -2426.844844844800'
    orientation = '-1219 0 625'
    length = 1029.8137466431315497906037378549111856734274905914330325658709398128891119815951012845583455723940079060997436706937542731921405
    names = ${hs_names}
    widths = ${hs_widths}
    materials = ${hs_materials}
    n_part_elems = ${n_part_elems_well}
    inner_radius = ${fparse pipe_dia/2}
    n_elems = ${n_elems}
  []

  [HT_pipe7]
    type = HeatTransferFromHeatStructure1Phase
    flow_channel = pipe7
    hs = HS_pipe7
    hs_side = INNER
    P_hf = ${fparse 2 * pi * (pipe_dia/2)}
  []

  [T_pipe7]
    type = HSBoundaryExternalAppTemperature
    hs = HS_pipe7
    boundary = HS_pipe7:outer
    T_ext = T_ext
    #Hw = 25000
  []

  [jct8]
    type = VolumeJunction1Phase
    position = '1 0 -1957'
    connections = 'pipe7:out production_pipe:in'
    volume = ${fparse 0.0001 * pi * pipe_dia * pipe_dia / 4.}
  []

  [production_pipe]
    type = FlowChannel1Phase
    position = '1 0 -1957'
    orientation = '0 0 1'
    length = 1957
    n_elems = ${n_elems}
    A = ${fparse pi * pipe_dia * pipe_dia / 4.}
    D_h = ${pipe_dia}
    #roughness = 1e-5
  []

  [HS_production_pipe]
    type = HeatStructureCylindrical
    position = '1 0 -1957'
    orientation = '0 0 1'
    length = 1957
    names = ${hs_names}
    widths = ${hs_widths}
    materials = ${hs_materials}
    n_part_elems = ${n_part_elems_well}
    inner_radius = ${fparse pipe_dia/2}
    n_elems = ${n_elems}
  []

  [HT_production_pipe]
    type = HeatTransferFromHeatStructure1Phase
    flow_channel = production_pipe
    hs = HS_production_pipe
    hs_side = INNER
    P_hf = ${fparse 2 * pi * (pipe_dia/2)}
  []

  [T_production_pipe]
    type = HSBoundaryExternalAppTemperature
    hs = HS_production_pipe
    boundary = HS_production_pipe:outer
    T_ext = T_ext
    #Hw = 25000
  []


  [outlet]
    type = Outlet1Phase
    input = 'production_pipe:out'
    p = 2e+6
  []


[]

[ControlLogic]
  [set_point]
    type = TimeFunctionComponentControl
    component = outlet
    parameter = p
    function = pressure_set
  []
[]



[Postprocessors]

  [rho_fracture1_in]
    type = ADSideAverageMaterialProperty
    property = rho
    boundary = fracture1:in
    #execute_on = 'initial timestep_end'
  []

  [rho_fracture1_out]
    type = ADSideAverageMaterialProperty
    property = rho
    boundary = fracture1:out
    #execute_on = 'initial timestep_end'
  []

  [rho_fracture2_in]
    type = ADSideAverageMaterialProperty
    property = rho
    boundary = fracture2:in
    #execute_on = 'initial timestep_end'
  []

  [rho_fracture2_out]
    type = ADSideAverageMaterialProperty
    property = rho
    boundary = fracture2:out
    #execute_on = 'initial timestep_end'
  []

  [rho_fracture3_in]
    type = ADSideAverageMaterialProperty
    property = rho
    boundary = fracture3:in
    #execute_on = 'initial timestep_end'
  []

  [rho_fracture3_out]
    type = ADSideAverageMaterialProperty
    property = rho
    boundary = fracture3:out
    #execute_on = 'initial timestep_end'
  []

  [mu_fracture1_in]
    type = ADSideAverageMaterialProperty
    property = mu
    boundary = fracture1:in
    #execute_on = 'initial timestep_end'
  []

  [mu_fracture1_out]
    type = ADSideAverageMaterialProperty
    property = mu
    boundary = fracture1:out
    #execute_on = 'initial timestep_end'
  []

  [mu_fracture2_in]
    type = ADSideAverageMaterialProperty
    property = mu
    boundary = fracture2:in
    #execute_on = 'initial timestep_end'
  []

  [mu_fracture2_out]
    type = ADSideAverageMaterialProperty
    property = mu
    boundary = fracture2:out
    #execute_on = 'initial timestep_end'
  []

  [mu_fracture3_in]
    type = ADSideAverageMaterialProperty
    property = mu
    boundary = fracture3:in
    #execute_on = 'initial timestep_end'
  []

  [mu_fracture3_out]
    type = ADSideAverageMaterialProperty
    property = mu
    boundary = fracture3:out
    #execute_on = 'initial timestep_end'
  []

  [permeability_fracture1_in]
    type = ParsedPostprocessor
    function = '(m_dot_fracture1_in * mu_fracture1_in * 98.06447557162307005210248929005225739881232750283853044679409922670562628737052780066190947088625665447598227063665130067648666298)/(${A_frac} * rho_fracture1_in * ((pressure_drop_fracture1/145.038)*1e6))'
    pp_names = 'rho_fracture1_in mu_fracture1_in pressure_drop_fracture1 m_dot_fracture1_in'
  []

  [permeability_fracture1_out]
    type = ParsedPostprocessor
    function = '(m_dot_fracture1_out * mu_fracture1_out * 98.06447557162307005210248929005225739881232750283853044679409922670562628737052780066190947088625665447598227063665130067648666298)/(${A_frac} * rho_fracture1_out * ((pressure_drop_fracture1/145.038)*1e6))'
    pp_names = 'rho_fracture1_out mu_fracture1_out pressure_drop_fracture1 m_dot_fracture1_out'
  []

  [permeability_fracture2_in]
    type = ParsedPostprocessor
    function = '(m_dot_fracture2_in * mu_fracture2_in * 97.90155581456182682116814463820372338064703154335045984390718274800565840279098911916336721242085105005555949462757708549479806153)/(${A_frac} * rho_fracture2_in * ((pressure_drop_fracture2/145.038)*1e6))'
    pp_names = 'rho_fracture2_in mu_fracture2_in pressure_drop_fracture2 m_dot_fracture2_in'
  []

  [permeability_fracture2_out]
    type = ParsedPostprocessor
    function = '(m_dot_fracture2_out * mu_fracture2_out * 97.90155581456182682116814463820372338064703154335045984390718274800565840279098911916336721242085105005555949462757708549479806153)/(${A_frac} * rho_fracture2_out * ((pressure_drop_fracture2/145.038)*1e6))'
    pp_names = 'rho_fracture2_out mu_fracture2_out pressure_drop_fracture2 m_dot_fracture2_out'
  []

  [permeability_fracture3_in]
    type = ParsedPostprocessor
    function = '(m_dot_fracture3_in * mu_fracture3_in * 100.1617127018392107082677912904102391759840600506092245079207843746364902370741653573756231075282759892565263907571110035070651488)/(${A_frac} * rho_fracture3_in * ((pressure_drop_fracture3/145.038)*1e6))'
    pp_names = 'rho_fracture3_in mu_fracture3_in pressure_drop_fracture3 m_dot_fracture3_in'
  []

  [permeability_fracture3_out]
    type = ParsedPostprocessor
    function = '(m_dot_fracture3_out * mu_fracture3_out * 100.1617127018392107082677912904102391759840600506092245079207843746364902370741653573756231075282759892565263907571110035070651488)/(${A_frac} * rho_fracture3_out * ((pressure_drop_fracture3/145.038)*1e6))'
    pp_names = 'rho_fracture3_out mu_fracture3_out pressure_drop_fracture3 m_dot_fracture3_out'
  []


  [m_dot_inlet]
    type = ADFlowBoundaryFlux1Phase
    boundary = inlet
    equation = mass
    #execute_on = 'initial timestep_end'
  []

  [m_dot_outlet]
    type = ADFlowBoundaryFlux1Phase
    boundary = outlet
    equation = mass
    #execute_on = 'initial timestep_end'
  []

  [m_dot_fracture1_in]
    type = ADFlowJunctionFlux1Phase
    boundary = fracture1:in
    connection_index = 1
    equation = mass
    junction = jct_fracture1_perf1
  []

  [m_dot_fracture2_in]
    type = ADFlowJunctionFlux1Phase
    boundary = fracture2:in
    connection_index = 1
    equation = mass
    junction = jct_fracture2_perf1
  []

  [m_dot_fracture3_in]
    type = ADFlowJunctionFlux1Phase
    boundary = fracture3:in
    connection_index = 1
    equation = mass
    junction = jct4
  []

  [m_dot_fracture1_out]
    type = ADFlowJunctionFlux1Phase
    boundary = fracture1:out
    connection_index = 1
    equation = mass
    junction = jct_fracture1_perf2
  []

  [m_dot_fracture2_out]
    type = ADFlowJunctionFlux1Phase
    boundary = fracture2:out
    connection_index = 1
    equation = mass
    junction = jct_fracture2_perf2
  []

  [m_dot_fracture3_out]
    type = ADFlowJunctionFlux1Phase
    boundary = fracture3:out
    connection_index = 1
    equation = mass
    junction = jct5
  []

  [T_fracture1_in]
    type = SideAverageValue
    variable = T
    boundary = fracture1:in
    execute_on = 'initial timestep_end'
  []

  [T_fracture2_in]
    type = SideAverageValue
    variable = T
    boundary = fracture2:in
    execute_on = 'initial timestep_end'
  []
  [T_fracture3_in]
    type = SideAverageValue
    variable = T
    boundary = fracture3:in
    execute_on = 'initial timestep_end'
  []

  [T_fracture1_out]
    type = SideAverageValue
    variable = T
    boundary = fracture1:out
    execute_on = 'initial timestep_end'
  []

  [T_fracture2_out]
    type = SideAverageValue
    variable = T
    boundary = fracture2:out
    execute_on = 'initial timestep_end'
  []
  [T_fracture3_out]
    type = SideAverageValue
    variable = T
    boundary = fracture3:out
    execute_on = 'initial timestep_end'
  []

  [production_pressure]
    type = PointValue
    point = '1 0 0'
    variable = p
  []

  [injection_pressure]
    type = PointValue
    point = '0 0 0'
    variable = p
  []

  [pressure_in_fracture1]
    type = SideAverageValue
    variable = p
    boundary = fracture1:in
    #execute_on = 'initial timestep_end'
  []

  [pressure_out_fracture1]
    type = SideAverageValue
    variable = p
    boundary = fracture1:out
    #execute_on = 'initial timestep_end'
  []

  [pressure_drop_fracture1]
    type = ParsedPostprocessor
    function = 'abs(((pressure_in_fracture1-pressure_out_fracture1)/1E6)*145.038)'
    pp_names = 'pressure_in_fracture1 pressure_out_fracture1'
  []

  [pressure_in_fracture2]
    type = SideAverageValue
    variable = p
    boundary = fracture2:in
    #execute_on = 'initial timestep_end'
  []

  [pressure_out_fracture2]
    type = SideAverageValue
    variable = p
    boundary = fracture2:out
    #execute_on = 'initial timestep_end'
  []

  [pressure_drop_fracture2]
    type = ParsedPostprocessor
    function = 'abs(((pressure_in_fracture2-pressure_out_fracture2)/1E6)*145.038)'
    pp_names = 'pressure_in_fracture2 pressure_out_fracture2'
  []

  [pressure_in_fracture3]
    type = SideAverageValue
    variable = p
    boundary = fracture3:in
    #execute_on = 'initial timestep_end'
  []

  [pressure_out_fracture3]
    type = SideAverageValue
    variable = p
    boundary = fracture3:out
    #execute_on = 'initial timestep_end'
  []

  [pressure_drop_fracture3]
    type = ParsedPostprocessor
    function = 'abs(((pressure_in_fracture3-pressure_out_fracture3)/1E6)*145.038)'
    pp_names = 'pressure_in_fracture3 pressure_out_fracture3'
  []

  [velocity_outlet]
    type = PointValue
    point = '1 0 0'
    variable = v
  []

  [pressure_drop_PSI]
    type = ParsedPostprocessor
    function = 'abs(((production_pressure-injection_pressure)/1E6)*145.038)'
    pp_names = 'injection_pressure production_pressure'
  []

  [Reynolds_Number]
    type = ParsedPostprocessor
    function = '(velocity_outlet*${pipe_dia}*${rho})/${mu}'
    pp_names = 'velocity_outlet'
  []

[]

[VectorPostprocessors]
  [injection_pipe_p]
    type = LineValueSampler
    end_point = '2.5191e-13 0 -2057'
    num_points = ${n_elems}
    sort_by = id
    start_point = '0 0 0'
    variable = p
  []
  [pipe2_p]
    type = LineValueSampler
    start_point = '0 0 -2057'
    num_points = ${n_elems}
    sort_by = id
    end_point = '917.2628469944179905237284145455130972923168953946769672922514350400815052032321574658006540686632290474425835111147119320437630922 0 -2526.909245386484594269195298688753957508758813365313557859909689964089591181860735467159281488075729251431323242298074332452450738'
    variable = p
  []
  [fracture1_perf1_p]
    type = LineValueSampler
    start_point = '917.2628469944179905237284145455130972923168953946769672922514350400815052032321574658006540686632290474425835111147119320437630922 0 -2526.909245386484594269195298688753957508758813365313557859909689964089591181860735467159281488075729251431323242298074332452450738'
    num_points = ${n_elems}
    sort_by = id
    end_point = '917.2640715887635062834115530595287571423114269995985565389745578363781123295742702131049701012118303296315318327300212436365165211 0 -2525.909246136300530915750627247711166403549964920278722743402239864263751285450154055487598036978552800096569157090603612969180998'
    variable = p
  []
  [fracture1_p]
    type = LineValueSampler
    end_point = '917.3841607910444842403168614859843401500054683950784107532768772037033928736578872526956839674513987178110516783846906884072465711 0 -2427.84484409498406335344467144104279110520884844503483511650745009982583989641058141167168345109717645133475408520747071948326974'
    num_points = ${n_elems}
    sort_by = id
    start_point = '917.2640715887635062834115530595287571423114269995985565389745578363781123295742702131049701012118303296315318327300212436365165211 0 -2525.909246136300530915750627247711166403549964920278722743402239864263751285450154055487598036978552800096569157090603612969180998'
    variable = p
  []
  [fracture1_perf2_p]
    type = LineValueSampler
    start_point = '917.3841607910444842403168614859843401500054683950784107532768772037033928736578872526956839674513987178110516783846906884072465711 0 -2427.84484409498406335344467144104279110520884844503483511650745009982583989641058141167168345109717645133475408520747071948326974'
    num_points = ${n_elems}
    sort_by = id
    end_point = '917.38538538539 0 -2426.8448448448'
    variable = p
  []

  [pipe3_p]
    type = LineValueSampler
    end_point = '1036.623501254473153353695992567689810142073162932761581504125430266367144607918901712056764268364150987947190195844173158087648307 0 -2588.057121544299880839884822606056650585394581577628555251497900931876080971135686326999209103703554919539146874069777053205958393'
    num_points = ${n_elems}
    sort_by = id
    start_point = '917.2628469944179905237284145455130972923168953946769672922514350400815052032321574658006540686632290474425835111147119320437630922 0 -2526.909245386484594269195298688753957508758813365313557859909689964089591181860735467159281488075729251431323242298074332452450738'
    variable = p
  []
  [fracture2_perf1_p]
    type = LineValueSampler
    end_point = '1036.626939296150546154407449105679820299916123611320944397219835889881242544348211203595554565618487396521315082047359428279718699 0 -2587.057127454382633123905626459237936030272054366214222394840134153701923618110508657226030905547389892324123110947853904640256311'
    num_points = ${n_elems}
    sort_by = id
    start_point = '1036.623501254473153353695992567689810142073162932761581504125430266367144607918901712056764268364150987947190195844173158087648307 0 -2588.057121544299880839884822606056650585394581577628555251497900931876080971135686326999209103703554919539146874069777053205958393'
    variable = p
  []
  [fracture2_p]
    type = LineValueSampler
    end_point = '1036.963528925322607199288543462009989842157039321440637106905594376485902063570690508461209702745663591425875113796813729807929608 0 -2489.156150246117247715979196146818714555122527211414332856657766778174157353025177669773178198156165027215023763121923148565702082'
    num_points = ${n_elems}
    sort_by = id
    start_point = '1036.626939296150546154407449105679820299916123611320944397219835889881242544348211203595554565618487396521315082047359428279718699 0 -2587.057127454382633123905626459237936030272054366214222394840134153701923618110508657226030905547389892324123110947853904640256311'
    variable = p
  []
  [fracture2_perf2_p]
    type = LineValueSampler
    end_point = '1036.96696696700 0 -2488.15615615620'
    num_points = ${n_elems}
    sort_by = id
    start_point = '1036.963528925322607199288543462009989842157039321440637106905594376485902063570690508461209702745663591425875113796813729807929608 0 -2489.156150246117247715979196146818714555122527211414332856657766778174157353025177669773178198156165027215023763121923148565702082'
    variable = p
  []


  [pipe4_p]
    type = LineValueSampler
    start_point = '1036.623501254473153353695992567689810142073162932761581504125430266367144607918901712056764268364150987947190195844173158087648307 0 -2588.057121544299880839884822606056650585394581577628555251497900931876080971135686326999209103703554919539146874069777053205958393'
    num_points = ${n_elems}
    sort_by = id
    end_point = '1122.617427164558731241613786393149188176286014106565826646572729158866647577956995606874692005341674875432830107018885414872149641 0 -2632.111386867089632706818100151039030971087186774463879984164898425809558645248102213100492481793422376467688447104782164156139538'
    variable = p
  []
  [fracture3_p]
    type = LineValueSampler
    end_point = '1122.3823823824 0 -2531.9499499499'
    num_points = ${n_elems}
    sort_by = id
    start_point = '1122.617427164558731241613786393149188176286014106565826646572729158866647577956995606874692005341674875432830107018885414872149641 0 -2632.111386867089632706818100151039030971087186774463879984164898425809558645248102213100492481793422376467688447104782164156139538'
    variable = p
  []



  [pipe5_p]
    type = LineValueSampler
    start_point = '1122.3823823824 0 -2531.9499499499'
    num_points = ${n_elems}
    sort_by = id
    end_point = '1036.96696696700 0 -2488.15615615620'
    variable = p
  []
  [pipe6_p]
    type = LineValueSampler
    end_point = '917.38538538539 0 -2426.8448448448'
    num_points = ${n_elems}
    sort_by = id
    start_point = '1036.96696696700 0 -2488.15615615620'
    variable = p
  []
  [pipe7_p]
    type = LineValueSampler
    start_point = '917.38538538539 0 -2426.8448448448'
    num_points = ${n_elems}
    sort_by = id
    end_point = '1 0 -1957'
    variable = p
  []

  [production_pipe_p]
    type = LineValueSampler
    start_point = '1 0 -1957'
    num_points = ${n_elems}
    sort_by = id
    end_point = '1 0 0'
    variable = p
  []
[]

[Preconditioning]
  [./pc]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = 'bdf2'
  start_time = 0
  steady_state_detection = true


  [TimeStepper]
    type = SolutionTimeAdaptiveDT
    dt = 0.1
  []

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  end_time = 1000000
  dtmax = 1e+6
  dtmin = 1e-5

  line_search = basic
  solve_type = 'NEWTON'

  nl_rel_tol = 1e-5
  nl_abs_tol = 1e-5
  nl_max_its = 10
  l_tol = 1e-3
  l_max_its = 10

[]

[Outputs]
  print_linear_residuals = false
  [./exodus]
    type = Exodus

  [../]
  [./console]
    type = Console
    output_linear = true
    output_nonlinear = true
    interval = 1
  [../]

  [./CSV]
    type = CSV
    interval = 1
  [../]
[]
