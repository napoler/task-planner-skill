# 36 final-readthrough-src — 交付前整读审查检查点（只读）

## 实际读取行范围（逐行从第1行读到末行）
1 discipline.md: 1-777（5段:1-210/211-379/380-409/410-599/600-777）
2 task-planner/SKILL.md: 1-469
3 critical-rules.md: 1-263
4 critical-rules-verification.md: 1-72
5 verification-gate/SKILL.md: 1-122
6 critical-rules-dispatch.md: 1-332（2段:1-270/271-332）
7 agent-coverage.md: 1-130
8 selftest-decision-arbiter.sh: 1-111
9 template-mapping.md: 1-334（3段:1-297/298-317/317-334）
10 decision-arbiter.md: 1-64
11 仓根AGENTS.md: 1-89
锚:edit-spec.md 1-241 / user-session-log.md 1-68 / plan 1-85 全读。

## E项逐项落实核对（结论均落实；行号=最终文件）
E0 L66 28.9整行①-⑧齐; E1a L64③; E1b L64②; E2 L64后净增2行(65空/66E0/67空/68###29); E3 L28; E4 L55; E5 L185; E6 L188; E7 L397
E8 L132; E9 L133; E10 L124; E11 L136; E12 L268; E13 L346
E14 L10; E15 L134; E16 L204
E17 L24; E18 L40; E19 L68; E20 L95
E21 L53; E22 L225; E23 L3/4/5(frontmatter model/max/desc); E24 L16-19; E25 AGENTS.md L24(§2,count=1)
E26 L393; E27 L396; E28 L399; E29 L40(GLM-5.4强档,无max); E30 L39/40-41/43
E31 L305; E32 L245(复检重档GLM5.3未动); E33 L14; E34 L41; E35 L68(且残余风险清单已登记⇒PARTIAL)

## 全局一致性/自检
28.9八子条=8; 六载体28.9计数7/6/3/2/2/2全≥1; 旧片语仅L64一处「单次阻塞降级收口」,「仅单次降级收口停止」「并停止该目标迭代」=0; SKILL469≤581,discipline777=775+2; diff vs 9e42c0b=10files/42+/34-无额外文件; PARTIAL口径L40/L68一致; frontmatter GLM-5.4+max 与DA-02/Rule69(393/396/399)/agent-coverage(40)/template-mapping(305)/dispatch(245)锁步; 旧GLM-5.3仅历史注记(L399/L14/L16-18/selftest L40)与complex-planner(L13/30)/泛指档(L30/213),无现行表述; 无TODO/占位。

## 问题清单
PASS：无问题。37项(E0,E1a-E25,E26-E35)全部落实; selftest既有钉值未触(DA-01..16除DA-02逐字锚锁步外未改)。
