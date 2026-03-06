using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

# Resource type enum for choosing between Wood and Gold
ResourceType := enum { Wood, Gold }

TriggerSetup := class<concrete>:
    
    @editable Trigger : trigger_device = trigger_device{}
    @editable ResourceCost : int = 0
    @editable CostResourceType : ResourceType = ResourceType.Wood
    @editable ActorToTrigger : creative_prop = creative_prop{}
    @editable TargetMarker : creative_prop = creative_prop{}
    
    var Completed : logic = false

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
    
    var ClaimZoneActivated : logic = false

    OnBegin<override>()<suspends> : void =
        
        SpawnDevice.SpawnedEvent.Subscribe(OnPlayerSpawned)
        ClaimZone.AgentEntersEvent.Subscribe(OnAgentEntersClaimZone)
        WoodCollector_Manipulation.DamagedEvent.Subscribe(OnHarvestingProp)
        GoldCollector_Zone.AgentEntersEvent.Subscribe(OnAgentGoldCollectorZone)
        
        if (Triggers.Length > 0):
            if (Phase0 := Triggers[0]):
                Phase0.Trigger.TriggeredEvent.Subscribe(HandleTrigger0)
        
        if (Triggers.Length > 1):
            if (Phase1 := Triggers[1]):
                Phase1.Trigger.TriggeredEvent.Subscribe(HandleTrigger1)
        
        if (Triggers.Length > 2):
            if (Phase2 := Triggers[2]):
                Phase2.Trigger.TriggeredEvent.Subscribe(HandleTrigger2)
        
        if (Triggers.Length > 3):
            if (Phase3 := Triggers[3]):
                Phase3.Trigger.TriggeredEvent.Subscribe(HandleTrigger3)
        
        if (Triggers.Length > 4):
            if (Phase4 := Triggers[4]):
                Phase4.Trigger.TriggeredEvent.Subscribe(HandleTrigger4)
        
        if (Triggers.Length > 5):
            if (Phase5 := Triggers[5]):
                Phase5.Trigger.TriggeredEvent.Subscribe(HandleTrigger5)
        
        if (Triggers.Length > 6):
            if (Phase6 := Triggers[6]):
                Phase6.Trigger.TriggeredEvent.Subscribe(HandleTrigger6)
        
        if (Triggers.Length > 7):
            if (Phase7 := Triggers[7]):
                Phase7.Trigger.TriggeredEvent.Subscribe(HandleTrigger7)

        set ResourcesUI.WoodCount = InitializeUICount
        set ResourcesUI.GoldCount = InitializeUICount

        spawn { HideAllTriggers() }

        loop:
            set GoldCount += 1
            GoldCount_DisplayText.SetText(TextForUI("{GoldCount}"))
            Sleep(1.0)

    HideAllTriggers()<suspends> : void =
        for (Phase : Triggers):
            HideTrigger(Phase)

    ShowFirstTrigger() : void =
        if (Triggers.Length > 0):
            if (FirstPhase := Triggers[0]):
                ShowTrigger(FirstPhase)

    ShowTrigger(Phase : TriggerSetup) : void =
        Phase.Trigger.Enable()
        
        TriggerTransform := Phase.Trigger.GetTransform()
        OriginalLocation := vector3:
            X := TriggerTransform.Translation.X
            Y := TriggerTransform.Translation.Y
            Z := TriggerTransform.Translation.Z + 1500.0
        if (Phase.Trigger.TeleportTo[OriginalLocation, TriggerTransform.Rotation]):
            void

    HideTrigger(Phase : TriggerSetup) : void =
        Phase.Trigger.Disable()
        
        TriggerTransform := Phase.Trigger.GetTransform()
        HiddenLocation := vector3:
            X := TriggerTransform.Translation.X
            Y := TriggerTransform.Translation.Y
            Z := TriggerTransform.Translation.Z - 1500.0
        if (Phase.Trigger.TeleportTo[HiddenLocation, TriggerTransform.Rotation]):
            void

    HandleTrigger0(MaybeAgent : ?agent) : void = spawn { ProcessBuilding(0) }
    HandleTrigger1(MaybeAgent : ?agent) : void = spawn { ProcessBuilding(1) }
    HandleTrigger2(MaybeAgent : ?agent) : void = spawn { ProcessBuilding(2) }
    HandleTrigger3(MaybeAgent : ?agent) : void = spawn { ProcessBuilding(3) }
    HandleTrigger4(MaybeAgent : ?agent) : void = spawn { ProcessBuilding(4) }
    HandleTrigger5(MaybeAgent : ?agent) : void = spawn { ProcessBuilding(5) }
    HandleTrigger6(MaybeAgent : ?agent) : void = spawn { ProcessBuilding(6) }
    HandleTrigger7(MaybeAgent : ?agent) : void = spawn { ProcessBuilding(7) }

    # Process the building for a specific Trigger Index
    ProcessBuilding(TriggerIndex : int)<suspends> : void =
        if (Phase := Triggers[TriggerIndex]):
            
            if (Phase.Completed = true):
                return
            
            if (Phase.CostResourceType = ResourceType.Wood):
                if (WoodCount >= Phase.ResourceCost):
                    set WoodCount -= Phase.ResourceCost
                    set ResourcesUI.WoodCount = TextForUI("{WoodCount}")
                    
                    BuildActor(Phase)
                    
                    set Phase.Completed = true
                    
                    HideTrigger(Phase)
                    
                    NextIndex := TriggerIndex + 1
                    if (NextIndex < Triggers.Length):
                        if (NextPhase := Triggers[NextIndex]):
                            ShowTrigger(NextPhase)
            
            else if (Phase.CostResourceType = ResourceType.Gold):
                if (TotalGold >= Phase.ResourceCost):
                    set TotalGold -= Phase.ResourceCost
                    set ResourcesUI.GoldCount = TextForUI("{TotalGold}")
                    
                    BuildActor(Phase)
                    
                    set Phase.Completed = true
                    
                    HideTrigger(Phase)
                    
                    NextIndex := TriggerIndex + 1
                    if (NextIndex < Triggers.Length):
                        if (NextPhase := Triggers[NextIndex]):
                            ShowTrigger(NextPhase)

    BuildActor(Phase : TriggerSetup) : void =
        TargetTransform := Phase.TargetMarker.GetTransform()
        TargetLoc := TargetTransform.Translation
        
        CurrentTransform := Phase.ActorToTrigger.GetTransform()
        
        if (Phase.ActorToTrigger.TeleportTo[TargetLoc, CurrentTransform.Rotation]):
            void

    OnPlayerSpawned(SpawnedAgent : agent) : void =
        if (Player := player[SpawnedAgent]):
            if (PlayerUI := GetPlayerUI[Player]):
                PlayerUI.AddWidget(ResourcesUI)
        
    OnAgentEntersClaimZone(Agent : agent) : void =
        if (Player := player[Agent]):
            if (ClaimZoneActivated = false):
                set ClaimZoneActivated = true
                
                Transform := MoveClaimZone.GetTransform()
                
                CurrentLoc := Transform.Translation
                NewLocation := vector3:
                    X := CurrentLoc.X
                    Y := CurrentLoc.Y
                    Z := CurrentLoc.Z - 1500.0
                
                if (MoveClaimZone.TeleportTo[NewLocation, Transform.Rotation]):
                    WoodCollector_Manipulation.Enable()
                    
                    ShowFirstTrigger()

    OnHarvestingProp(Agent : agent) : void =
        if (Player := player[Agent]):
            set WoodCount += 1
            set ResourcesUI.WoodCount = TextForUI("{WoodCount}")

    OnAgentGoldCollectorZone(Agent : agent) : void =
        if (Player := player[Agent]):
            set TotalGold += GoldCount
            set ResourcesUI.GoldCount = TextForUI("{TotalGold}")
            set GoldCount = 0
            GoldCount_DisplayText.SetText(TextForUI("{GoldCount}"))