"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const userService_1 = require("../src/services/userService");
describe('buildHomeSummary', () => {
    it('constructs summary with pattern cards and actions', () => {
        const user = {
            displayName: 'Test User',
            email: 'test@example.com',
            level: 2,
            locale: 'ko-KR',
            timezone: 'Asia/Seoul',
            preferences: {
                hapticsEnabled: true,
                soundEnabled: true,
                pushOptIn: true,
                effectMode: 'full',
                dailyGoalSentences: 12,
                dailyGoalMinutes: 12,
            },
            stats: {
                currentStreak: 5,
                longestStreak: 7,
                brainTokens: 2,
                streakFreezesAvailable: 1,
                patternConquestCount: 3,
                sessionsCompletedThisWeek: 4,
                lastSessionAt: new Date().toISOString(),
                subscriptionStatus: 'free',
                brainBurstActive: true,
                brainBurstMultiplier: 2,
                brainBurstEligibleAt: new Date(Date.now() + 86400000).toISOString(),
            },
            flags: {
                levelTestCompleted: true,
                tutorialCompleted: true,
                personalizationReady: true,
            },
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
        const summary = (0, userService_1.buildHomeSummary)(user);
        expect(summary.dailyGoal.sentences).toBe(12);
        expect(summary.progress.sentencesCompleted).toBeGreaterThan(0);
        expect(summary.patternCards.length).toBeGreaterThan(0);
        expect(summary.recommendedActions.length).toBeGreaterThan(0);
        expect(summary.liveActivity.supported).toBe(true);
    });
});
