import 'package:kyber_mod_manager/utils/types/mode.dart';

final List<Mode> modes = modesFromJson([
  {
    "mode": "HeroesVersusVillains",
    "name": "Heroes Versus Villains",
    "maps": [
      "S5_1/Levels/MP/Geonosis_01/Geonosis_01",
      "Levels/MP/Naboo_02/Naboo_02",
      "Levels/MP/Kashyyyk_01/Kashyyyk_01",
      "S8/Felucia/Levels/MP/Felucia_01/Felucia_01",
      "S7_2/Levels/Naboo_03/Naboo_03",
      "S6_2/Geonosis_02/Levels/Geonosis_02/Geonosis_02",
      "S3/Levels/Kessel_01/Kessel_01",
      "S9_3/Scarif/Levels/MP/Scarif_02/Scarif_02",
      "Levels/MP/Tatooine_01/Tatooine_01",
      "Levels/MP/Yavin_01/Yavin_01",
      "Levels/MP/Hoth_01/Hoth_01",
      "S2/Levels/CloudCity_01/CloudCity_01",
      "S2_2/Levels/JabbasPalace_01/JabbasPalace_01",
      "Levels/MP/Endor_01/Endor_01",
      "Levels/MP/DeathStar02_01/DeathStar02_01",
      "Levels/MP/Jakku_01/Jakku_01",
      "Levels/MP/Takodana_01/Takodana_01",
      "Levels/MP/StarKiller_01/StarKiller_01",
      "S9_3/Crait/Crait_02",
      "S9/Paintball/Levels/MP/Paintball_01/Paintball_01",
      "S9/Takodana_02/Takodana_02",
      "S9/Jakku_02/Jakku_02"
    ],
    "mapOverrides": [
      {"map": "Levels/MP/Tatooine_01/Tatooine_01", "name": "Tatooine - Mos Eisley"},
      {"map": "S2_2/Levels/JabbasPalace_01/JabbasPalace_01", "name": "Tatooine - Jabba's Palace"},
      {"map": "S7_2/Levels/Naboo_03/Naboo_03", "name": "Republic Venator"},
      {"map": "S6_2/Geonosis_02/Levels/Geonosis_02/Geonosis_02", "name": "Separatist Dreadnought"},
      {"map": "S9/Jakku_02/Jakku_02", "name": "Resurgent Star Destroyer"},
      {"map": "S9/Takodana_02/Takodana_02", "name": "MC85 Star Cruiser"}
    ]
  },
  {
    "mode": "PlanetaryBattles",
    "name": "Galactic Assault",
    "maps": [
      "S5_1/Levels/MP/Geonosis_01/Geonosis_01",
      "Levels/MP/Kamino_01/Kamino_01",
      "Levels/MP/Naboo_01/Naboo_01",
      "Levels/MP/Kashyyyk_01/Kashyyyk_01",
      "Levels/MP/Tatooine_01/Tatooine_01",
      "Levels/MP/Yavin_01/Yavin_01",
      "Levels/MP/Hoth_01/Hoth_01",
      "Levels/MP/Endor_01/Endor_01",
      "Levels/MP/DeathStar02_01/DeathStar02_01",
      "Levels/MP/Jakku_01/Jakku_01",
      "Levels/MP/Takodana_01/Takodana_01",
      "Levels/MP/StarKiller_01/StarKiller_01",
      "S1/Levels/Crait_01/Crait_01"
    ]
  },
  {
    "mode": "Mode1",
    "name": "Supremacy",
    "maps": [
      "S6_2/Geonosis_02/Levels/Geonosis_02/Geonosis_02",
      "S7_1/Levels/Kamino_03/Kamino_03",
      "S7_2/Levels/Naboo_03/Naboo_03",
      "S7/Levels/Kashyyyk_02/Kashyyyk_02",
      "S8/Felucia/Levels/MP/Felucia_01/Felucia_01",
      "S9_3/Scarif/Levels/MP/Scarif_02/Scarif_02",
      "S9_3/Tatooine_02/Tatooine_02",
      "Levels/MP/Yavin_01/Yavin_01",
      "S9_3/Hoth_02/Hoth_02",
      "Levels/MP/DeathStar02_01/DeathStar02_01",
      "S9/Jakku_02/Jakku_02",
      "S9/Takodana_02/Takodana_02",
      "S9/StarKiller_02/StarKiller_02",
      "S9/Paintball/Levels/MP/Paintball_01/Paintball_01"
    ]
  },
  {
    "mode": "Mode9",
    "name": "CO-OP Attack",
    "maps": [
      "S5_1/Levels/MP/Geonosis_01/Geonosis_01",
      "Levels/MP/Kamino_01/Kamino_01",
      "S7_2/Levels/Naboo_03/Naboo_03",
      "S7/Levels/Kashyyyk_02/Kashyyyk_02",
      "S8/Felucia/Levels/MP/Felucia_01/Felucia_01",
      "S7_1/Levels/Kamino_03/Kamino_03",
      "S6_2/Geonosis_02/Levels/Geonosis_02/Geonosis_02",
      "S3/Levels/Kessel_01/Kessel_01",
      "S9_3/Scarif/Levels/MP/Scarif_02/Scarif_02",
      "Levels/MP/Tatooine_01/Tatooine_01",
      "Levels/MP/Yavin_01/Yavin_01",
      "Levels/MP/Hoth_01/Hoth_01",
      "S2_2/Levels/JabbasPalace_01/JabbasPalace_01",
      "Levels/MP/Endor_01/Endor_01",
      "Levels/MP/DeathStar02_01/DeathStar02_01",
      "S9/Jakku_02/Jakku_02",
      "S9/Takodana_02/Takodana_02",
      "S9/StarKiller_02/StarKiller_02",
      "S9/Paintball/Levels/MP/Paintball_01/Paintball_01",
      "S9_3/COOP_NT_MC85/COOP_NT_MC85",
      "S9_3/COOP_NT_FOSD/COOP_NT_FOSD"
    ],
    "mapOverrides": [
      {"map": "S6_2/Geonosis_02/Levels/Geonosis_02/Geonosis_02", "name": "Separatist Dreadnought"},
      {"map": "S7_1/Levels/Kamino_03/Kamino_03", "name": "Republic Venator"},
      {"map": "Levels/MP/Tatooine_01/Tatooine_01", "name": "Tatooine - Mos Eisley"},
      {"map": "S2_2/Levels/JabbasPalace_01/JabbasPalace_01", "name": "Tatooine - Jabba's Palace"}
    ]
  },
  {
    "mode": "ModeDefend",
    "name": "CO-OP Defend",
    "maps": [
      "S5_1/Levels/MP/Geonosis_01/Geonosis_01",
      "Levels/MP/Kamino_01/Kamino_01",
      "S7_2/Levels/Naboo_03/Naboo_03",
      "S7/Levels/Kashyyyk_02/Kashyyyk_02",
      "S8/Felucia/Levels/MP/Felucia_01/Felucia_01",
      "S7_1/Levels/Kamino_03/Kamino_03",
      "S6_2/Geonosis_02/Levels/Geonosis_02/Geonosis_02",
      "S3/Levels/Kessel_01/Kessel_01",
      "S9_3/Scarif/Levels/MP/Scarif_02/Scarif_02",
      "Levels/MP/Tatooine_01/Tatooine_01",
      "Levels/MP/Yavin_01/Yavin_01",
      "Levels/MP/Hoth_01/Hoth_01",
      "S2_2/Levels/JabbasPalace_01/JabbasPalace_01",
      "Levels/MP/Endor_01/Endor_01",
      "Levels/MP/DeathStar02_01/DeathStar02_01",
      "S9/Jakku_02/Jakku_02",
      "S9/Takodana_02/Takodana_02",
      "S9/StarKiller_02/StarKiller_02",
      "S9/Paintball/Levels/MP/Paintball_01/Paintball_01",
      "S9_3/COOP_NT_MC85/COOP_NT_MC85",
      "S9_3/COOP_NT_FOSD/COOP_NT_FOSD"
    ],
    "mapOverrides": [
      {"map": "S6_2/Geonosis_02/Levels/Geonosis_02/Geonosis_02", "name": "Separatist Dreadnought"},
      {"map": "S7_1/Levels/Kamino_03/Kamino_03", "name": "Republic Venator"},
      {"map": "Levels/MP/Tatooine_01/Tatooine_01", "name": "Tatooine - Mos Eisley"},
      {"map": "S2_2/Levels/JabbasPalace_01/JabbasPalace_01", "name": "Tatooine - Jabba's Palace"}
    ]
  },
  {
    "mode": "PlanetaryMissions",
    "name": "Strike",
    "maps": [
      "Levels/MP/Kamino_01/Kamino_01",
      "Levels/MP/Naboo_01/Naboo_01",
      "Levels/MP/Kashyyyk_01/Kashyyyk_01",
      "Levels/MP/Tatooine_01/Tatooine_01",
      "Levels/MP/Yavin_01/Yavin_01",
      "Levels/MP/Hoth_01/Hoth_01",
      "Levels/MP/Endor_01/Endor_01",
      "Levels/MP/DeathStar02_01/DeathStar02_01",
      "Levels/MP/Jakku_01/Jakku_01",
      "Levels/MP/Takodana_01/Takodana_01",
      "Levels/MP/StarKiller_01/StarKiller_01",
      "S1/Levels/Crait_01/Crait_01"
    ],
    "mapOverrides": [
      {"map": "S1/Levels/Crait_01/Crait_01", "name": "Crait (WIP)"}
    ]
  },
  {
    "mode": "Mode5",
    "name": "Extraction",
    "maps": ["S3/Levels/Kessel_01/Kessel_01", "S2_2/Levels/JabbasPalace_01/JabbasPalace_01"]
  },
  {
    "mode": "Blast",
    "name": "Blast",
    "maps": [
      "S5_1/Levels/MP/Geonosis_01/Geonosis_01",
      "Levels/MP/Kamino_01/Kamino_01",
      "Levels/MP/Naboo_01/Naboo_01",
      "Levels/MP/Naboo_02/Naboo_02",
      "Levels/MP/Kashyyyk_01/Kashyyyk_01",
      "S3/Levels/Kessel_01/Kessel_01",
      "Levels/MP/Tatooine_01/Tatooine_01",
      "Levels/MP/Yavin_01/Yavin_01",
      "Levels/MP/Hoth_01/Hoth_01",
      "S2/Levels/CloudCity_01/CloudCity_01",
      "S2_2/Levels/JabbasPalace_01/JabbasPalace_01",
      "Levels/MP/Endor_01/Endor_01",
      "S2_1/Levels/Endor_02/Endor_02",
      "Levels/MP/DeathStar02_01/DeathStar02_01",
      "Levels/MP/Jakku_01/Jakku_01",
      "Levels/MP/Takodana_01/Takodana_01",
      "Levels/MP/StarKiller_01/StarKiller_01",
      "S1/Levels/Crait_01/Crait_01"
    ],
    "mapOverrides": [
      {"map": "Levels/MP/Tatooine_01/Tatooine_01", "name": "Tatooine - Mos Eisley"},
      {"map": "Levels/MP/Naboo_02/Naboo_02", "name": "Naboo - Palace Hangar"},
      {"map": "S2_2/Levels/JabbasPalace_01/JabbasPalace_01", "name": "Tatooine - Jabba's Palace"},
      {"map": "Levels/MP/Endor_01/Endor_01", "name": "Endor - Research Station 9"},
      {"map": "S2_1/Levels/Endor_02/Endor_02", "name": "Endor - Ewok Village (WIP)"},
      {"map": "Levels/MP/Naboo_01/Naboo_01", "name": "Naboo - Theed Palace"}
    ]
  },
  {
    "mode": "Mode3",
    "name": "Ewok Hunt",
    "maps": ["S2_1/Levels/Endor_02/Endor_02", "S8_1/Endor_04/Endor_04"]
  },
  {
    "mode": "ModeC",
    "name": "Jetpack Cargo",
    "maps": ["Levels/MP/Tatooine_01/Tatooine_01", "Levels/MP/Yavin_01/Yavin_01", "S2/Levels/CloudCity_01/CloudCity_01"]
  },
  {
    "mode": "SpaceBattle",
    "name": "Starfighter Assault",
    "maps": [
      "Levels/Space/SB_DroidBattleShip_01/SB_DroidBattleShip_01",
      "Levels/Space/SB_Kamino_01/SB_Kamino_01",
      "Levels/Space/SB_Fondor_01/SB_Fondor_01",
      "Levels/Space/SB_Endor_01/SB_Endor_01",
      "Levels/Space/SB_Resurgent_01/SB_Resurgent_01",
      "S1/Levels/Space/SB_SpaceBear_01/SB_SpaceBear_01"
    ]
  },
  {
    "mode": "Mode7",
    "name": "Hero Starfighters",
    "maps": [
      "Levels/Space/SB_DroidBattleShip_01/SB_DroidBattleShip_01",
      "Levels/Space/SB_Kamino_01/SB_Kamino_01",
      "Levels/Space/SB_Fondor_01/SB_Fondor_01",
      "Levels/Space/SB_Endor_01/SB_Endor_01",
      "Levels/Space/SB_Resurgent_01/SB_Resurgent_01",
      "S1/Levels/Space/SB_SpaceBear_01/SB_SpaceBear_01"
    ]
  },
  {
    "mode": "Mode6",
    "name": "Hero Showdown",
    "maps": [
      "S5_1/Levels/MP/Geonosis_01/Geonosis_01",
      "Levels/MP/Kamino_01/Kamino_01",
      "Levels/MP/Naboo_02/Naboo_02",
      "Levels/MP/Kashyyyk_01/Kashyyyk_01",
      "S8/Felucia/Levels/MP/Felucia_01/Felucia_01",
      "S7_2/Levels/Naboo_03/Naboo_03",
      "S6_2/Geonosis_02/Levels/Geonosis_02/Geonosis_02",
      "S3/Levels/Kessel_01/Kessel_01",
      "S9_3/Scarif/Levels/MP/Scarif_02/Scarif_02",
      "Levels/MP/Tatooine_01/Tatooine_01",
      "Levels/MP/Yavin_01/Yavin_01",
      "Levels/MP/Hoth_01/Hoth_01",
      "S2/Levels/CloudCity_01/CloudCity_01",
      "S2_2/Levels/JabbasPalace_01/JabbasPalace_01",
      "Levels/MP/Endor_01/Endor_01",
      "Levels/MP/DeathStar02_01/DeathStar02_01",
      "Levels/MP/Jakku_01/Jakku_01",
      "Levels/MP/Takodana_01/Takodana_01",
      "Levels/MP/StarKiller_01/StarKiller_01",
      "S9_3/Crait/Crait_02",
      "S9/Paintball/Levels/MP/Paintball_01/Paintball_01",
      "S9/Takodana_02/Takodana_02",
      "S9/Jakku_02/Jakku_02"
    ],
    "mapOverrides": [
      {"map": "Levels/MP/Tatooine_01/Tatooine_01", "name": "Tatooine - Mos Eisley"},
      {"map": "S2_2/Levels/JabbasPalace_01/JabbasPalace_01", "name": "Tatooine - Jabba's Palace"},
      {"map": "S7_2/Levels/Naboo_03/Naboo_03", "name": "Republic Venator"},
      {"map": "S6_2/Geonosis_02/Levels/Geonosis_02/Geonosis_02", "name": "Separatist Dreadnought"},
      {"map": "S9/Jakku_02/Jakku_02", "name": "Resurgent Star Destroyer"},
      {"map": "S9/Takodana_02/Takodana_02", "name": "MC85 Star Cruiser"}
    ]
  }
]);
