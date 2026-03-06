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
    
    # Track if this trigger has been completed
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

    OnBegin<override>()<suspends> : void =
        
        SpawnDevice.SpawnedEvent.Subscribe(OnPlayerSpawned)
        ClaimZone.AgentEntersEvent.Subscribe(OnAgentEntersClaimZone)
        WoodCollector_Manipulation.DamagedEvent.Subscribe(OnHarvestingProp)
        GoldCollector_Zone.AgentEntersEvent.Subscribe(OnAgentGoldCollectorZone)
        
        # Subscribe each trigger to its own specific handler (8 triggers: 0-7)
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

        # Initialize triggers - hide all except the first one
        spawn { InitializeTriggers() }

        loop:
            set GoldCount += 1
            GoldCount_DisplayText.SetText(TextForUI("{GoldCount}"))
            Sleep(1.0)

    # Initialize triggers - show only the first one, hide others
    InitializeTriggers()<suspends> : void =
        # First, hide all triggers
        for (Phase : Triggers):
            HideTrigger(Phase)
        
        # Then show only the first trigger (index 0) if it exists
        if (Triggers.Length > 0):
            if (FirstPhase := Triggers[0]):
                ShowTrigger(FirstPhase)

    # Show a trigger (enable and bring it up)
    ShowTrigger(Phase : TriggerSetup) : void =
        # Enable the trigger
        Phase.Trigger.Enable()
        
        # Teleport it back to original position - FIXED: Create new location vector
        TriggerTransform := Phase.Trigger.GetTransform()
        OriginalLocation := vector3:
            X := TriggerTransform.Translation.X
            Y := TriggerTransform.Translation.Y
            Z := TriggerTransform.Translation.Z + 1500.0
        if (Phase.Trigger.TeleportTo[OriginalLocation, TriggerTransform.Rotation]):
            void

    # Hide a trigger (disable and move it down)
    HideTrigger(Phase : TriggerSetup) : void =
        # Disable the trigger
        Phase.Trigger.Disable()
        
        # Move it down to hide it - FIXED: Create new location vector
        TriggerTransform := Phase.Trigger.GetTransform()
        HiddenLocation := vector3:
            X := TriggerTransform.Translation.X
            Y := TriggerTransform.Translation.Y
            Z := TriggerTransform.Translation.Z - 1500.0
        if (Phase.Trigger.TeleportTo[HiddenLocation, TriggerTransform.Rotation]):
            void

    # Individual handlers for each trigger (8 triggers: 0-7)
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
        # Safely access the array element
        if (Phase := Triggers[TriggerIndex]):
            
            # Check if this trigger is already completed
            if (Phase.Completed = true):
                return
            
            # Check the appropriate resource based on CostResourceType
            if (Phase.CostResourceType = ResourceType.Wood):
                # Check if player has enough wood
                if (WoodCount >= Phase.ResourceCost):
                    # Deduct wood
                    set WoodCount -= Phase.ResourceCost
                    set ResourcesUI.WoodCount = TextForUI("{WoodCount}")
                    
                    # Build the house part
                    BuildActor(Phase)
                    
                    # Mark as completed
                    set Phase.Completed = true
                    
                    # Disable and hide the current trigger
                    HideTrigger(Phase)
                    
                    # Show the next trigger if it exists
                    NextIndex := TriggerIndex + 1
                    if (NextIndex < Triggers.Length):
                        if (NextPhase := Triggers[NextIndex]):
                            ShowTrigger(NextPhase)
            
            else if (Phase.CostResourceType = ResourceType.Gold):
                # Check if player has enough gold
                if (TotalGold >= Phase.ResourceCost):
                    # Deduct gold
                    set TotalGold -= Phase.ResourceCost
                    set ResourcesUI.GoldCount = TextForUI("{TotalGold}")
                    
                    # Build the house part
                    BuildActor(Phase)
                    
                    # Mark as completed
                    set Phase.Completed = true
                    
                    # Disable and hide the current trigger
                    HideTrigger(Phase)
                    
                    # Show the next trigger if it exists
                    NextIndex := TriggerIndex + 1
                    if (NextIndex < Triggers.Length):
                        if (NextPhase := Triggers[NextIndex]):
                            ShowTrigger(NextPhase)

    BuildActor(Phase : TriggerSetup) : void =
        # Get target location from marker
        TargetTransform := Phase.TargetMarker.GetTransform()
        TargetLoc := TargetTransform.Translation
        
        # Get current transform
        CurrentTransform := Phase.ActorToTrigger.GetTransform()
        
        # Teleport to target
        if (Phase.ActorToTrigger.TeleportTo[TargetLoc, CurrentTransform.Rotation]):
            void

    OnPlayerSpawned(SpawnedAgent : agent) : void =
        if (Player := player[SpawnedAgent]):
            if (PlayerUI := GetPlayerUI[Player]):
                PlayerUI.AddWidget(ResourcesUI)
        
    OnAgentEntersClaimZone(Agent : agent) : void =
        if (Player := player[Agent]):
            Transform := MoveClaimZone.GetTransform()
            
            # FIXED: Create new location vector
            CurrentLoc := Transform.Translation
            NewLocation := vector3:
                X := CurrentLoc.X
                Y := CurrentLoc.Y
                Z := CurrentLoc.Z - 1500.0
            
            # Teleport claim zone
            if (MoveClaimZone.TeleportTo[NewLocation, Transform.Rotation]):
                # Enable wood harvesting
                WoodCollector_Manipulation.Enable()

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