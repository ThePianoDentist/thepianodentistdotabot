run = 72 --dynamic

function neural_net(values)

    ---------------------
    --ML parameters
    -------------------
    local weights_1 = {}
    weights_1[1] = {0.0635919751609} --dynamic
    weights_1[2] = {-2.46523438208} --dynamic
    weights_1[3] = {-2.96821243761} --dynamic
    weights_1[4] = {-4.23649907446} --dynamic

    weights_1[5] = {0.159490438492} --dynamic
    weights_1[6] = {-2.32752674775} --dynamic
    weights_1[7] = {0.101896438236} --dynamic
    weights_1[8] = {0.490668861813} --dynamic

    weights_1[9] = {-2.26447146935} --dynamic
    weights_1[10] = {-1.58280190145} --dynamic
    weights_1[11] = {2.47884327491} --dynamic
    weights_1[12] = {-2.85101543468} --dynamic
    weights_1[13] = {0.259435014043} --dynamic -- TODO check this actually gets updated by regex replace. may need to fix that

    --------------------------
    local weights_0 = {}
    weights_0[1] = {{-0.591095859472},{0.756234872782},{-0.945224813604},{0.337214585097},{-0.165390395266},{0.117379656512},{-0.71922612281},{-0.60379702183},{0.601489137351},{1.06320739425},{-0.821170053203},{0.384642559888},{0.752778304592},} --dynamic  "p_hero_attackrange"
    weights_0[2] = {{0.789213325596},{-0.82991157726},{-0.921890433534},{-0.660353790379},{0.756285006859},{-0.803306332335},{-0.15778474999},{0.915779060301},{0.066330569946},{0.384252376096},{-0.370730437446},{0.373001844858},{0.669251343795},} --dynamic  "p_hero_attackspeed"
    weights_0[3] = {{-0.96342426052},{0.50028862989},{0.977722177813},{0.487881506643},{-0.439112015871},{0.578558656041},{-0.793547986845},{-0.104212947648},{0.817191006186},{-0.125048168741},{-1.44198265971},{-0.739948923127},{-0.961266084259},} --dynamic  "p_hero_attackdamage"
    weights_0[4] = {{0.35767100626},{-0.576743768},{-0.468906681256},{-0.0174716520419},{-0.893274909766},{0.148235210921},{-0.706542850188},{0.178611073807},{0.399516720042},{-0.774288674895},{-0.246304641536},{0.388799871723},{-0.171641460946},} --dynamic   "p_hero_movespeed"

    weights_0[5] = {{-0.900093082108},{0.071792811831},{0.32758929044},{0.0297719183422},{0.889189511982},{0.173110081003},{0.806803830576},{-0.725050591708},{-0.721447305498},{0.615104656034},{-0.205405679215},{-0.669291612558},{0.855017160792},} --dynamic   "p_damage_spread_neutral"
    weights_0[6] = {{-0.304468280509},{0.501624206272},{0.451995970701},{0.754580690338},{0.247344414111},{0.501884867199},{-0.302203316044},{-0.46014421647},{0.791772436392},{0.302809850666},{-0.406920064056},{0.326876330412},{0.243391440418},} --dynamic   "p_neutral_total_eff_hp"
    weights_0[7] = {{-0.770508054093},{0.898978517414},{-0.10017573304},{0.156779301048},{-0.183726394477},{-0.525946039514},{0.806759041125},{0.147358973345},{-0.994259345938},{0.293648839233},{-0.398595427687},{0.0541162045152},{0.771884198622},} --dynamic  "p_targeted_neutral_eff_hp"
    weights_0[8] = {{-0.285460480725},{0.81707030184},{0.246720231584},{-0.968365081255},{0.858874467488},{0.381793835033},{0.994645700903},{-0.655318983309},{-0.725728500742},{0.865534476576},{0.392686096461},{-0.867999656367},{0.510926105205},} --dynamic    "p_fraction_neutral_left"

    weights_0[9] = {{0.507750512894},{0.846049071093},{0.423049517257},{-0.770779074388},{-0.96023973232},{-0.947578027305},{-0.943387023958},{-0.507577864794},{0.720055897366},{0.860884034617},{-2.22123271541},{0.684060091291},{-0.75165336976},} --dynamic   "p_damage_spread_lane"
    weights_0[10] = {{-0.441632641978},{0.171518542917},{0.939191496639},{0.122060438511},{-0.962705421254},{0.601265345361},{-0.534051452318},{0.614210391238},{-0.224278711872},{0.727083709119},{0.494243285474},{0.112480467981},{-0.727089548679},} --dynamic    "p_fraction_lane_left"
    weights_0[11] = {{-0.880164620976},{-0.757313088519},{-0.91089624291},{-0.785011741404},{-0.548581322784},{0.425977960764},{0.119433964108},{-0.974888039682},{-0.856051440621},{0.935408585711},{0.13581089749},{-0.593413539734},{-0.495348510859},} --dynamic   "p_targeted_lane_eff_hp"
    weights_0[12] = {{0.48765170815},{-0.609141037781},{0.162717854547},{0.940039978177},{0.69365760298},{-0.520304481705},{-0.0124605714625},{0.239911436763},{0.6579617991},{-0.686417210708},{-0.962847595645},{-0.859955712562},{-0.0273097781259},} --dynamic   "p_lane_total_eff_hp"

    local inputs = {}
    inputs[1] = values["hero_attackrange"]
    inputs[2] = values["hero_attackspeed"]
    inputs[3] = values["hero_attackdamage"]
    inputs[4] = values["hero_movespeed"]

    inputs[5] = values["damage_spread_neutral"]
    inputs[6] = values["neutral_total_eff_hp"]
    inputs[7] = values["targeted_neutral_eff_hp"]
    inputs[8] = values["fraction_neutral_left"]

    inputs[9] = values["damage_spread_lane"]
    inputs[10] = values["fraction_lane_left"]
    inputs[11] = values["targeted_lane_eff_hp"]
    inputs[12] = values["lane_total_eff_hp"]
    inputs = {inputs}  -- wrapping to make 1x12. not 12x1
--    for i=1, #inputs do
--        inputs[i] = {inputs[i] }
--    end
--    for i=1, #weights_1 do
--        weights_1[i] = {weights_1[i] }
--    end

    local mul = matrix_mul(inputs, weights_0)
--    print("len mul: " .. tostring(#mul))
--    print("len mul[1]: " .. tostring(#mul[1]))
    local hidden_0 = sigmoid(mul)
--    print("len hidden0: " .. tostring(#hidden_0))
--    print("len weights_1: " .. tostring(#weights_1))
--    print("len hidden0[1]: " .. tostring(#hidden_0[1]))
--    print("len weights_1[1]: " .. tostring(#weights_1[1]))
    local output = sigmoid(matrix_mul(hidden_0, weights_1))
    -- TODO should be left with single value
--    print("#output[1]: " .. tostring(#output[1]))
--    print("#output: " .. tostring(#output))
    return output[1][1]
end


function matrix_mul( m1, m2 )
    -- TODO this allows invalid matrix multiplications it seems
    -- multiply rows with columns
    local mtx = {}
--    print("len m1, m1[1]: " .. tostring(#m1) .. ", " .. tostring(#m1[1]))
--    print("len m2, m2[1]: " .. tostring(#m2) .. ", " .. tostring(#m2[1]))
    for i = 1,#m1 do
        mtx[i] = {}
        for j = 1,#m2[1] do
--            print(m1[i][1])
--            print(m2[1][j][1])
-- TODO hmmmmmmmmmm. this should be consistent right? shouldnt need check if table or number and do different way
            local m2_elem = type(m2[1][j]) == "table" and m2[1][j][1] or m2[1][j]
            local num = m1[i][1] * m2_elem
            --print("mul num: " .. tostring(num))
                for n = 2,#m1[1] do
                    num = num + m1[i][n] * m2_elem
                end
            mtx[i][j] = num
        end
    end
    return mtx
end


function sigmoid(m)
    for i = 1, #m do
        --        print("len m[i]: " .. tostring(#m[i]))
        --        print("m[i][1]: " .. tostring(m[i][1]))
        for j = 1, #m[i] do
            m[i][j] = 1 / (1 + math.exp(-m[i][j]))
        end
    end
    return m
end

function vec_matrix_mul( m1, m2 )
    -- multiply rows with columns
    local mtx = {}
    for i = 1,#m1 do
        mtx[i] = {}
        for j = 1,#m2[1] do
            local num = m1[i] * m2[1][j][1]
            print("mul num: " .. tostring(num))
            --            for n = 2,#m1[1] do
            --                num = num + m1[i][n] * m2[n][j]
            --            end
            mtx[i][j] = num
        end
    end
    return mtx
end