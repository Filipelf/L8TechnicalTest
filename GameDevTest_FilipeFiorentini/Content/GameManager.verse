
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using {/UnrealEngine.com/Temporary/UI}
using {/UnrealEngine.com/Temporary/SpatialMath}
using { /UnrealEngine.com/Temporary/Diagnostics }

TriggerSetup := class<concrete>:
    
    @editable Trigger : trigger_device = trigger_device{}

    @editable ResourceCost : int = 0

    @editable ObjectsToTrigger : creative_prop = creative_prop{}

    @editable LocationToMoveObjects : vector3 = vector3{}

GameManager := class(creative_device):

    #Initialization:
    @editable SpawnDevice : player_spawner_device = player_spawner_device{}

    @editable ClaimZone : mutator_zone_device = mutator_zone_device{}
    @editable MoveClaimZone : creative_prop = creative_prop{}

    @editable WoodCollector_Manipulation : prop_manipulator_device = prop_manipulator_device{}

    @editable GoldCollector_Zone : mutator_zone_device = mutator_zone_device{}
    @editable GoldCount_DisplayText : billboard_device = billboard_device{}

    @editable Triggers : []TriggerSetup = array{}

    ResourcesUI : Widgets.W_HUD_Resources = Widgets.W_HUD_Resources{}
    InitializeUICount<localizes> : message = "0"
    TextForUI<localizes>(InText : string) : message = "{InText}"

    var WoodCount : int = 0
    var GoldCount : int = 0
    var TotalGold : int = 0

    #@editable var AddUITriggerDevice : trigger_device = trigger_device{}


    #@editable var Trigger : trigger_device = trigger_device{}
    #@editable var MoveObject : creative_prop = creative_prop{}
    #@editable var DesiredLocation : vector3 = vector3{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        
        SpawnDevice.SpawnedEvent.Subscribe(OnPlayerSpawned)

        ClaimZone.AgentEntersEvent.Subscribe(OnAgentEntersClaimZone)

        WoodCollector_Manipulation.DamagedEvent.Subscribe(OnHarvestingProp)

        GoldCollector_Zone.AgentEntersEvent.Subscribe(OnAgentGoldCollectorZone)

        #Trigger.TriggeredEvent.Subscribe(OnTriggeredTrigger)

        set ResourcesUI.WoodCount = InitializeUICount
        set ResourcesUI.GoldCount = InitializeUICount

        loop:
            set GoldCount += 1
            GoldCount_DisplayText.SetText(TextForUI("{GoldCount}"))
            Sleep(1.0)

    OnPlayerSpawned(SpawnedAgent : agent) :void=
        if (Player := player[SpawnedAgent]):
            if (PlayerUI := GetPlayerUI[Player]):
                PlayerUI.AddWidget(ResourcesUI)
        
    OnAgentEntersClaimZone(Agent : agent):void=
        if (Player := player[Agent]):
            Transform := MoveClaimZone.GetTransform()
            var Location : vector3 = Transform.Translation
            set Location.Z -= 1500.0
                if (MoveClaimZone.TeleportTo[Location, Transform.Rotation]){}

    OnHarvestingProp(Agent : agent):void=
        if (Player := player[Agent]):
            set WoodCount += 1
            set ResourcesUI.WoodCount = TextForUI("{WoodCount}")

    OnAgentGoldCollectorZone(Agent : agent):void=
        if (Player := player[Agent]):
            set TotalGold += GoldCount
            set ResourcesUI.GoldCount = TextForUI("{TotalGold}")
            set GoldCount = 0
            GoldCount_DisplayText.SetText(TextForUI("{GoldCount}"))

    <#OnTriggeredTrigger(MaybeAgent : ?agent):void=
        Transform := MoveClaimZone.GetTransform()
        if (WoodCount >= 3):
            if (MoveObject.TeleportTo[DesiredLocation, Transform.Rotation]){}#>

        