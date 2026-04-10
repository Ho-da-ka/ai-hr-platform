package com.company.hr.common.constant;

import lombok.Getter;

@Getter
public enum AiSuggestionTypeEnum {
    MATCH_SCORE("匹配评分"),
    INTERVIEW_QUESTIONS("面试问题"),
    COMMUNICATION_SCRIPT("沟通话术"),
    OFFER_ADVICE("Offer建议");

    private final String desc;

    AiSuggestionTypeEnum(String desc) {
        this.desc = desc;
    }
}
