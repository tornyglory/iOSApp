import Foundation

// MARK: - Program Instructions Data

struct ProgramInstructionsData {
    static func getInstructions(forProgramId programId: Int) -> ProgramInstructions? {
        print("🔍 Looking for instructions for program ID: \(programId)")
        print("📚 Available program IDs: \(allInstructions.keys.sorted())")
        let instructions = allInstructions[programId]
        if instructions != nil {
            print("✅ Found instructions for program \(programId)")
        } else {
            print("❌ No instructions found for program \(programId)")
        }
        return instructions
    }

    private static let allInstructions: [Int: ProgramInstructions] = [
        1: program1Instructions,  // 100 Bowl Challenge
        3: program2Instructions,  // Draw Shot Mastery
        4: program3Instructions   // Weighted Shot Clinic
    ]

    // MARK: - Program 1: 100 Bowl Challenge

    private static let program1Instructions = ProgramInstructions(
        programId: 1,
        title: "100 Bowl Challenge",
        difficulty: .intermediate,
        duration: 90,
        totalShots: 100,
        category: "Fundamentals",
        bestFor: "Players comfortable with all shot types who want a comprehensive workout",
        imageUrl: "https://imagedelivery.net/m72F7lhvPE70s0P_bHotiw/142ea700-f89c-4ed1-9d9b-9c83f49e3500/public",
        whatYouNeed: [
            "Your lawn bowls",
            "A full-length rink (ideally outdoor)",
            "A jack",
            "Chalk or markers (optional - for tracking positions)",
            "Water bottle - stay hydrated!",
            "Towel for wiping bowls",
            "90-120 minutes of uninterrupted practice time"
        ],
        setupSteps: [
            InstructionStep(
                title: "Choose Your Rink",
                description: "Choose a quiet rink where you won't be disturbed for about 90-120 minutes. Make sure you have access to the full length of the green."
            ),
            InstructionStep(
                title: "Prepare Your Equipment",
                description: "Have your bowls, jack, and any markers ready at the mat. Keep your water bottle nearby. 💡 TIP: Consider placing CDs on the green at target positions - they stay in place and you can bowl right over them for consistent target practice."
            ),
            InstructionStep(
                title: "Warm Up",
                description: "Before starting the program, roll 4-6 practice shots to warm up your delivery and get a feel for the green speed.",
                duration: "5 minutes"
            ),
            InstructionStep(
                title: "Set Jack Positions",
                description: "You'll be changing jack lengths throughout the program: Short jack (23-25m), Medium jack (27-29m), Long jack (31+m). Mark these positions with chalk if helpful."
            ),
            InstructionStep(
                title: "Ready Your App",
                description: "Keep your phone easily accessible to record each shot. Consider using a phone holder or placing it on a stable surface where you can see the screen between shots."
            )
        ],
        tips: [
            "Pace Yourself: This is 100 shots - take short breaks between sets of 10",
            "Stay Focused: Each shot matters. Don't rush through the sequence",
            "Track Your Score: Try to beat your previous best score",
            "Mix It Up: The program alternates shot types to keep you sharp",
            "Finish Strong: The final 10 shots are draw shots - perfect your technique",
            "Record Notes: Use the notes feature to track what's working"
        ],
        structure: ProgramStructure(
            overview: "This program includes 50 draw shots, 20 yard on, 20 ditch weight, and 10 drives. Shots alternate between forehand and backhand.",
            phases: [
                ProgramPhase(
                    name: "Warm-up Phase",
                    shots: "Shots 1-10",
                    description: "Short draw shots to ease into the session"
                ),
                ProgramPhase(
                    name: "Fundamentals",
                    shots: "Shots 11-50",
                    description: "Mixed draw shots at medium and long lengths with weighted shots introduced"
                ),
                ProgramPhase(
                    name: "Power Practice",
                    shots: "Shots 51-80",
                    description: "Focus on weighted shots - yard on and ditch weight"
                ),
                ProgramPhase(
                    name: "Challenge Phase",
                    shots: "Shots 81-90",
                    description: "Drive shots to test your power and accuracy"
                ),
                ProgramPhase(
                    name: "Cool-down",
                    shots: "Shots 91-100",
                    description: "Return to draw shots to finish with control and precision"
                )
            ],
            shotDistribution: ShotDistribution(draws: 50, yardOn: 20, ditchWeight: 20, drives: 10)
        ),
        warnings: [
            "Make sure you have permission to use the rink for 90-120 minutes",
            "Check that green conditions are suitable for practice",
            "Ensure you're physically warmed up to prevent injury",
            "Have water nearby to stay hydrated",
            "Consider practicing during off-peak hours"
        ],
        learningFocus: nil,
        safetyRequirements: nil,
        prerequisites: nil,
        notRecommendedIf: nil,
        performanceGoals: nil,
        advancedTips: nil
    )

    // MARK: - Program 3: Draw Shot Mastery

    private static let program2Instructions = ProgramInstructions(
        programId: 3,
        title: "Draw Shot Mastery",
        difficulty: .beginner,
        duration: 30,
        totalShots: 60,
        category: "Fundamentals",
        bestFor: "New players or those wanting to perfect their draw shot technique",
        imageUrl: "https://imagedelivery.net/m72F7lhvPE70s0P_bHotiw/142ea700-f89c-4ed1-9d9b-9c83f49e3500/public",
        whatYouNeed: [
            "Your lawn bowls",
            "A rink (any length)",
            "A jack",
            "Water bottle",
            "30-40 minutes of practice time",
            "Optional: A coach or experienced player to watch your technique"
        ],
        setupSteps: [
            InstructionStep(
                title: "Select Your Practice Area",
                description: "Find a rink where you can practice uninterrupted for 30-40 minutes. This program is perfect for beginners, so don't worry about using a 'beginner-friendly' green - every green helps you learn!"
            ),
            InstructionStep(
                title: "Equipment Check",
                description: "Have your bowls and jack ready at the mat. Since you'll be focusing only on draw shots, you won't need anything else. 💡 TIP: Place CDs on the green at target positions - they stay in place and you can bowl right over them for consistent aiming practice."
            ),
            InstructionStep(
                title: "Warm Up",
                description: "Roll a few practice bowls to get comfortable with the green speed and your delivery. Focus on smooth, consistent technique.",
                duration: "3-5 minutes"
            ),
            InstructionStep(
                title: "Mark Your Jack Lengths",
                description: "You'll practice at three different lengths: Short jack (23-25m for shots 1-20), Medium jack (27-29m for shots 21-40), Long jack (31+m for shots 41-60). Consider marking these spots with chalk for consistency."
            ),
            InstructionStep(
                title: "Phone Position",
                description: "Place your phone where you can easily record results after each shot without breaking your rhythm."
            )
        ],
        tips: [
            "Perfect Your Technique: This program is all about repetition and consistency",
            "Watch Your Line: Focus on delivering along the same line every time",
            "Grip and Release: Pay attention to how you're holding and releasing the bowl",
            "Body Position: Keep your stance consistent across all 60 shots",
            "Progressive Length: Start with short jacks to build confidence, then increase",
            "Hand Balance: The program alternates forehand/backhand to develop both equally",
            "Mental Focus: Even though it's 'just' draw shots, stay mentally engaged",
            "Track Improvement: Compare your accuracy across short, medium, and long jacks"
        ],
        structure: ProgramStructure(
            overview: "60 draw shots designed to build muscle memory through focused repetition. All shots alternate between forehand and backhand.",
            phases: [
                ProgramPhase(
                    name: "Phase 1: Short Jacks",
                    shots: "Shots 1-20",
                    description: "Master control and accuracy at shorter distances. Perfect for building confidence."
                ),
                ProgramPhase(
                    name: "Phase 2: Medium Jacks",
                    shots: "Shots 21-40",
                    description: "Develop consistency at the most common game length. Focus on maintaining technique with increased distance."
                ),
                ProgramPhase(
                    name: "Phase 3: Long Jacks",
                    shots: "Shots 41-60",
                    description: "Test your precision at maximum length. Build strength and control for challenging conditions."
                )
            ],
            shotDistribution: ShotDistribution(draws: 60, yardOn: 0, ditchWeight: 0, drives: 0)
        ),
        warnings: [
            "This is a beginner-friendly program - perfect for new players!",
            "Focus on technique over speed - quality matters more than quantity",
            "Don't rush between shots - take time to reset your stance",
            "If you're new to bowls, consider having someone watch your delivery",
            "This program is excellent for warming up before competitions"
        ],
        learningFocus: [
            "Consistency: Can you deliver the same way every time?",
            "Line: Are you able to hold your intended line?",
            "Weight Control: How well do you adjust for different jack lengths?",
            "Balance: Is your body position stable and repeatable?",
            "Follow-Through: Are you finishing your delivery smoothly?"
        ],
        safetyRequirements: nil,
        prerequisites: nil,
        notRecommendedIf: nil,
        performanceGoals: nil,
        advancedTips: nil
    )

    // MARK: - Program 4: Weighted Shot Clinic

    private static let program3Instructions = ProgramInstructions(
        programId: 4,
        title: "Weighted Shot Clinic",
        difficulty: .advanced,
        duration: 25,
        totalShots: 50,
        category: "Advanced",
        bestFor: "Experienced players wanting to develop attacking shot skills",
        imageUrl: "https://imagedelivery.net/m72F7lhvPE70s0P_bHotiw/142ea700-f89c-4ed1-9d9b-9c83f49e3500/public",
        whatYouNeed: [
            "Your lawn bowls",
            "A full-length rink (outdoor preferred)",
            "A jack",
            "Target bowls or markers (for practicing hitting)",
            "Water bottle",
            "25-35 minutes of practice time",
            "⚠️ Ensure no one is using adjacent rinks (drive shots travel wide)"
        ],
        setupSteps: [
            InstructionStep(
                title: "Safety First - Choose Your Rink Carefully",
                description: "⚠️ IMPORTANT: This program includes drive shots that can travel across adjacent rinks. Make sure adjacent rinks are empty or players are aware, you have clear sight lines, no one is walking in your shot path, and green management has approved power shot practice.",
                important: true
            ),
            InstructionStep(
                title: "Equipment Preparation",
                description: "Have your bowls and jack ready. 💡 BEST PRACTICE: Place CDs on the green at various target positions instead of bowls. CDs stay in place throughout your practice and you can bowl right over them without needing to reset targets. If CDs aren't available, you can use target bowls or mark positions with chalk."
            ),
            InstructionStep(
                title: "Warm Up",
                description: "⚠️ CRITICAL: Warm up thoroughly before attempting weighted shots. Roll 4-6 draw shots, do 3-4 yard on shots, stretch your arms/shoulders/legs, and practice your drive delivery motion without a bowl.",
                duration: "5-7 minutes",
                important: true
            ),
            InstructionStep(
                title: "Set Up Jack and Target Positions",
                description: "This program uses multiple jack lengths: Short jack (23-25m for yard on), Medium jack (27-29m for varied weighted shots), Long jack (31+m for ditch weight and drives). Place target bowls near these positions."
            ),
            InstructionStep(
                title: "Communication",
                description: "Let nearby players know you're practicing weighted shots. Consider practicing during quiet hours."
            )
        ],
        tips: [
            "Power Control: Start with yard on to build up to drives gradually",
            "Focus on Line: Weighted shots still need accurate line, not just power",
            "Smooth Delivery: Don't muscle the bowl - use smooth, controlled power",
            "Follow Through: Complete your delivery on weighted shots just like draws",
            "Rest Between Sets: Take short breaks to maintain form and prevent fatigue",
            "Track Accuracy: Weighted shots are about hitting targets, not just power",
            "Safety Awareness: Always check your surroundings before drive shots",
            "Learn Your Limits: This is practice - focus on technique, not max power"
        ],
        structure: ProgramStructure(
            overview: "Advanced program focused on developing attacking shots: 20 yard on, 20 ditch weight, and 10 drives.",
            phases: [
                ProgramPhase(
                    name: "Phase 1: Yard On Practice",
                    shots: "Shots 1-20",
                    description: "Build controlled power with yard on shots across all lengths. Learn to move bowls approximately 1 yard."
                ),
                ProgramPhase(
                    name: "Phase 2: Ditch Weight Shots",
                    shots: "Shots 21-40",
                    description: "Progress to heavier weighted shots. Practice removing opposition bowls to the ditch."
                ),
                ProgramPhase(
                    name: "Phase 3: Drive Shots",
                    shots: "Shots 41-50",
                    description: "Maximum power and accuracy. Test your ability to clear the head and develop confidence in firing shots."
                )
            ],
            shotDistribution: ShotDistribution(draws: 0, yardOn: 20, ditchWeight: 20, drives: 10)
        ),
        warnings: nil,
        learningFocus: nil,
        safetyRequirements: [
            "Check adjacent rinks are clear before drive shots",
            "Ensure clear sight lines down the green",
            "Communicate with other green users",
            "Stop immediately if anyone enters your shot path",
            "Follow green management rules for weighted shot practice"
        ],
        prerequisites: [
            "Be comfortable with draw shots at all lengths",
            "Have practiced weighted shots before",
            "Understand proper delivery technique for power shots",
            "Have good physical fitness and flexibility",
            "Know how to safely deliver drive shots"
        ],
        notRecommendedIf: [
            "You're experiencing any arm, shoulder, or back pain",
            "You're new to lawn bowls (try Draw Shot Mastery first)",
            "Weather conditions are poor (wet greens, strong winds)",
            "You haven't warmed up thoroughly"
        ],
        performanceGoals: PerformanceGoals(
            yardOn: "Aim to move target bowls consistently 0.5-1 yard",
            ditchWeight: "Try to remove at least 60% of target bowls to the ditch",
            drives: "Focus on hitting within 1 meter of target line"
        ),
        advancedTips: [
            "Yard On Technique: Use a slightly faster delivery with controlled release",
            "Ditch Weight Strategy: Aim for the middle of the target bowl",
            "Drive Delivery: Keep your head down and follow through completely",
            "Weight Adjustment: Feel the difference between yard on, ditch weight, and drive",
            "Target Practice: Set up specific scenarios (e.g., 'remove this bowl')",
            "Game Simulation: Imagine match situations as you practice"
        ]
    )
}
