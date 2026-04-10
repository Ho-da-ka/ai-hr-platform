package com.company.hr.common.constant;

import lombok.Getter;

import java.util.Arrays;
import java.util.List;

@Getter
public enum CandidateStageEnum {
    RESUME_SCREENING("简历筛选", 0),
    PHONE_INTERVIEW("电话面试", 1),
    FIRST_INTERVIEW("一面", 2),
    SECOND_INTERVIEW("二面", 3),
    FINAL_INTERVIEW("终面", 4),
    BACKGROUND_CHECK("背调", 5),
    OFFER_APPROVAL("Offer审批", 6),
    OFFER_SENT("Offer发放", 7),
    ONBOARDING("入职", 8),
    REJECTED("淘汰", -1);

    private final String desc;
    private final int order;

    CandidateStageEnum(String desc, int order) {
        this.desc = desc;
        this.order = order;
    }

    public CandidateStageEnum getNextStage() {
        if (this == REJECTED) {
            return null;
        }
        CandidateStageEnum[] stages = values();
        for (int i = 0; i < stages.length - 1; i++) {
            if (stages[i] == this) {
                return stages[i + 1];
            }
        }
        return null;
    }

    public static boolean canTransition(CandidateStageEnum from, CandidateStageEnum to) {
        if (to == REJECTED) {
            return true;
        }
        if (from == REJECTED) {
            return false;
        }
        return from.getNextStage() == to;
    }

    public static List<CandidateStageEnum> getActiveStages() {
        return Arrays.stream(values()).filter(s -> s != REJECTED).toList();
    }
}
