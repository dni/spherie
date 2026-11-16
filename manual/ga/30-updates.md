# Nuashonruithe

Coinnítear Spherie agus do phacáistí cothrom le dáta trí _Nuashonrú > Omarchy_ sa roghchlár Spherie (`Super + Space`).

Suiteáiltear Spherie féin mar ghnáthphacáistí pacman ó [Stór Pacáistí Spherie](https://github.com/omacom-io/omarchy-pkgs), mar sin suiteálann nuashonrú [an t-eisiúint Spherie is déanaí](https://github.com/omacom/omarchy/releases), ritheann sé aon aistrithe atá ar feitheamh chun do chóras a chur i sioncronú leis an leagan is déanaí, agus nuashonraíonn sé gach pacáiste córais ó [Scáthán Arch Spherie](https://github.com/omacom-io/omarchy-mirror) agus [AUR](https://aur.archlinux.org/) (má tá aon phacáistí AUR suiteáilte agat).

Nuair a dhéantar eisiúintí nua, beidh deilbhín saigheade i gciorcal le feiceáil ar dheis do chloig. Cliceáil é agus tosóidh an próiseas nuashonraithe.

![update-available](images/update-available.webp)

### Ceithre chainéal

Nuashonraítear Spherie feadh ceithre chainéal: stable, RC, edge, agus dev. Tosaíonn suiteálacha nua ar an gcainéal stable, a leanann na [heisiúintí oifigiúla](https://github.com/omacom/omarchy/releases/), chomh maith leis an [scáthán Arch Spherie stable](https://github.com/omacom-io/omarchy-mirror) atá mí amháin taobh thiar den leagan is déanaí, ionas gur féidir linn aon neamh-chomhoiriúnachtaí nua a dteastaíonn athruithe cumraíochta uathu a aimsiú sula gcuireann siad fadhbanna ar dhaoine.

Ach más mian leat cuidiú leis na fadhbanna féideartha sin a aimsiú, is féidir leat rith ar an gcainéal edge. Coinneoidh sé sin do phacáistí Spherie ag leanúint na leaganacha forbartha is déanaí, agus ligfidh sé duit nuashonrú go dtí na pacáistí Arch is déanaí chomh luath agus a bhíonn siad ar fáil. Níor cheart duit é seo a dhéanamh ach amháin má tá taithí agat ar Linux, agus má tá a fhios agat conas córas a bhfuil fadhbanna aige a aisghabháil.

Roimh aon mhóreisiúint nua, beimid ag déanamh bailíochtaithe deiridh ag baint úsáide as an gcainéal RC. Má tá suim agat cuidiú leis an snasú deiridh, tar isteach linn in #omarchy-release-candidates ar an Discord.

Ar deireadh, tá an cainéal dev ann, a nascann Spherie go díreach le seiceáil amach git den chód foinse in `~/omarchy`, in éineacht leis na pacáistí edge. Níor cheart duit an cainéal seo a úsáid ach amháin más úsáideoir Linux le taithí tú, ag obair go díreach ar Spherie, agus toilteanach glacadh le briseadh.

Is féidir leat malartú idir cainéil trí _Nuashonrú > Channel_ a úsáid ón roghchlár Spherie (nó `omarchy-channel-set` sa teirminéal).

### Ag malartú eithní

Tosaíonn Spherie lena eithne `linux-omarchy` féin, ach is féidir leat cinn eile a choinneáil suiteáilte in aice leis, cosúil leis an eithne caighdeánach Arch `linux` nó leagan turgnamhach atá á thástáil agat. Nuair a bhíonn níos mó ná ceann amháin ann, liostaíonn _Nuashonrú > Kernel_ sa roghchlár Spherie iad le tic in aice leis an gceann a thosaíonn de réir réamhshocraithe. Roghnaigh ceann eile, cuir isteach do phasfhocal uair amháin, agus tosóidh sé tar éis an chéad atosaigh eile. Fanann na heithní eile sa roghchlár tosaithe, mar sin is féidir leat ceann a roghnú de láimh fós má thugann an réamhshocrú nua trioblóid duit. Sa teirminéal, is é `omarchy-kernel` é chun an réamhshocrú reatha a fheiceáil, `omarchy-kernel list` don mhéid atá suiteáilte, agus `omarchy-kernel set <kernel>` chun malartú.

### Nuashonruithe dochtearraí

Ní hiad do phacáistí an t-aon rud a théann i léig. Seachadann go leor ríomhairí glúine agus forimeallach dochtearraí BIOS, SSD, agus dugála tríd an Linux Vendor Firmware Service, agus faigheadh agus suiteálfaidh _Nuashonrú > Firmware_ sa roghchlár Spherie cibé rud atá ag fanacht le do chrua-earraí. Suiteálann sé `fwupd` an chéad uair a ritheann tú é. Ní féidir go leor dochtearraí a scríobh ach amháin le linn atosaigh, mar sin ná bíodh iontas ort má iarrtar ceann ort.

Nuair a chaithfidh tú socrú sa BIOS féin a athrú, coinnigh `Alt` sa roghchlár córais (`Super + Escape`) agus athraíonn _Reboot_ go _Reboot to BIOS_, a atosóidh díreach isteach sa socrú dochtearraí gan ort an eochair cheart a aimsiú ag an tosú. Ón teirminéal, is é `omarchy system firmware` é.

### Rabhadh faoi nuashonruithe díreacha pacman/yay

Má tá tú eolach ar Arch cheana féin, d'fhéadfá a bheith meallta chun `pacman -Syu` nó `yay -Syu` a rith tú féin, ach má dhéanann tú é sin, caillfidh tú an seat, na haistrithe, agus na nuashonruithe cumraíochta a ritheann Spherie in éineacht le pacáistí nua. Sin é an fáth go stopfaidh Spherie uasghrádú díreach córais agus go dtabharfaidh sé treoir duit go `omarchy update` ina áit. (Má tá a fhios agat i ndáiríre cad atá á dhéanamh agat, inseoidh an garda duit conas é a sheachbhóthar le haghaidh idirbhirt amháin.)

### Ag aisrolladh drochnuashonruithe

Má bhíonn fadhb agat riamh tar éis nuashonrú a dhéanamh, is féidir leat do chóras a aisrolladh go dtí an seat a tógadh roimh an nuashonrú. Ní gá ach atosú agus an seat sa roghchlár luchtaithe tosaithe ó sular thosaigh tú an nuashonrú a roghnú.

![bootloader](images/bootloader.webp)

Má tá do chomhaid chumraíochta truaillithe ar bhealach éigin, is féidir leat athshuiteáil Spherie a dhéanamh freisin trí `omarchy reinstall` a úsáid sa teirminéal. Athshuiteálfaidh sé seo gach pacáiste réamhshocraithe Spherie, cuirfidh sé ar stable thú agus íosghrádóidh sé aon phacáistí atá ró-nua, agus athshocróidh sé na comhaid chumraíochta go léir. Tabhair faoi deara go bhforscríobhfar gach athrú cumraíochta úsáideora a rinne tú ar réamhshocruithe Spherie agus é seo á dhéanamh!
