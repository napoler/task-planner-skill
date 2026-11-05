# Skill Audit - task-skillfix-20261105
Date: 2026-11-04
Skills: task-planner, plan-resume
Auditor: skill-definition quality inspector (read-only)

=== validate_skill task-planner ===
{
  "valid": true,
  "errors": [],
  "warnings": [
    "No task() or TaskCreate references",
    "Standard 10: SKILL.md has no @config.json reference"
  ],
  "info": {
    "name": "task-planner",
    "description_length": 169,
    "forbidden_apis_documented_only": true,
    "total_lines": 274
  }
}

=== validate_skill plan-resume ===
{
  "valid": true,
  "errors": [],
  "warnings": [
    "No task() or TaskCreate references",
    "Standard 10: SKILL.md has no @config.json reference"
  ],
  "info": {
    "name": "plan-resume",
    "description_length": 622,
    "forbidden_apis_documented_only": true,
    "total_lines": 438
  }
}

=== path_existence_validator task-planner ===
          "status": "AMBIGUOUS",
          "severity": "P1",
          "actual": "/home/terry/.zcode/skills/task-discipline/references/execution-recall-card.md",
          "hint": "存在于 sibling，建议加 ../references 前缀"
        },
        {
          "path": "references/critical-rules.md",
          "status": "OK",
          "severity": null
        },
        {
          "path": "references/critical-rules-dispatch.md",
          "status": "AMBIGUOUS",
          "severity": "P1",
          "actual": "/home/terry/.zcode/skills/task-dispatch/references/critical-rules-dispatch.md",
          "hint": "存在于 sibling，建议加 ../references 前缀"
        },
        {
          "path": "references/critical-rules-discipline.md",
          "status": "AMBIGUOUS",
          "severity": "P1",
          "actual": "/home/terry/.zcode/skills/task-discipline/references/critical-rules-discipline.md",
          "hint": "存在于 sibling，建议加 ../references 前缀"
        },
        {
          "path": "references/critical-rules-media.md",
          "status": "AMBIGUOUS",
          "severity": "P1",
          "actual": "/home/terry/.zcode/skills/media-planner/references/critical-rules-media.md",
          "hint": "存在于 sibling，建议加 ../references 前缀"
        },
        {
          "path": "references/critical-rules-research.md",
          "status": "AMBIGUOUS",
          "severity": "P1",
          "actual": "/home/terry/.zcode/skills/plan-research-router/references/critical-rules-research.md",
          "hint": "存在于 sibling，建议加 ../references 前缀"
        },
        {
          "path": "references/critical-rules-template.md",
          "status": "AMBIGUOUS",
          "severity": "P1",
          "actual": "/home/terry/.zcode/skills/plan-template-kit/references/critical-rules-template.md",
          "hint": "存在于 sibling，建议加 ../references 前缀"
        },
        {
          "path": "references/critical-rules-collab.md",
          "status": "AMBIGUOUS",
          "severity": "P1",
          "actual": "/home/terry/.zcode/skills/plan-collab-router/references/critical-rules-collab.md",
          "hint": "存在于 sibling，建议加 ../references 前缀"
        },
        {
          "path": "references/critical-rules-cost.md",
          "status": "AMBIGUOUS",
          "severity": "P1",
          "actual": "/home/terry/.zcode/skills/plan-cost-guard/references/critical-rules-cost.md",
          "hint": "存在于 sibling，建议加 ../references 前缀"
        },
        {

=== path_existence_validator plan-resume ===
          "status": "MISSING",
          "severity": "P0",
          "actual": null,
          "hint": "文件在根目录和 skill 子目录均不存在"
        },
        {
          "path": "scripts/scan-plans.sh",
          "status": "OK",
          "severity": null,
          "actual_path": ".zcode/skills/plan-resume/scripts/scan-plans.sh"
        },
        {
          "path": "scripts/extract-meta.sh",
          "status": "OK",
          "severity": null,
          "actual_path": ".zcode/skills/plan-resume/scripts/extract-meta.sh"
        },

=== detect_drift task-planner ===
{
  "skill": "/mnt/data/dev/task-planner-skill/skills/task-planner",
  "drift_issues": [
    {
      "type": "config_not_externalized",
      "pattern": "@config.json",
      "message": "SKILL.md has no @config.json reference",
      "check": "path_patterns"
    },
    {
      "type": "state_rmw_no_lock",
      "file": "scripts/register-hooks-cj.ts",
      "message": "State read-modify-write without lockfile/wx/O_EXCL",
      "severity": "P1",
      "check": "parallel_safety"
    }
  ],
  "steps_extracted": [],
  "checks": {
    "serial_vs_parallel": [],
    "model_overrides": [],
    "path_patterns": [
      {
        "type": "config_not_externalized",
        "pattern": "@config.json",
        "message": "SKILL.md has no @config.json reference",
        "check": "path_patterns"
      }
    ],
    "agent_routing": []
  },
  "parallel_safety": {
    "standard": 76,
    "scope": "/mnt/data/dev/task-planner-skill/skills/task-planner/scripts + /mnt/data/dev/task-planner-skill/skills/task-planner/tools",
    "issue_count": 1,
    "issues": [
      {
        "type": "state_rmw_no_lock",
        "file": "scripts/register-hooks-cj.ts",
        "message": "State read-modify-write without lockfile/wx/O_EXCL",
        "severity": "P1",
        "check": "parallel_safety"
      }
    ]
  },
  "hardcoded_paths": {
    "standard": "75-D4",
    "scope": "/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md + references/ + scripts/*.ts,*.sh + tools/*.ts",
    "issues": [
      {
        "file": "scripts/check-dispatch.sh",
        "line": 23,
        "snippet": "#   ② prompt 自声明(三文件路径同目录三件齐 且 task_plan.md 真实存在,兼容 /home 与 /mnt/data",
        "type": "hardcoded_data_disk",
        "fix_suggestion": "用环境变量或 @configurable CONFIG 区登记替代写死的 /mnt 数据盘路径",
        "severity": "P1"
      },
      {
        "file": "scripts/check-dispatch.sh",
        "line": 33,
        "snippet": "#   现象 = 混拼写 prompt(task_plan 行 /home、findings 行 /mnt/data、progress 行 /home)在 en",
        "type": "hardcoded_data_disk",
        "fix_suggestion": "用环境变量或 @configurable CONFIG 区登记替代写死的 /mnt 数据盘路径",
        "severity": "P1"
      },
      {
        "file": "scripts/check-dispatch.sh",
        "line": 130,
        "snippet": "# 取舍=身份类缺项须免疫 /home 与 /mnt/data 双视图拼写（bind mount 不折叠路径），",
        "type": "hardcoded_data_disk",
        "fix_suggestion": "用环境变量或 @configurable CONFIG 区登记替代写死的 /mnt 数据盘路径",
        "severity": "P1"
      },
      {
        "file": "scripts/check-dispatch.sh",
        "line": 281,
        "snippet": "# 且该目录 task_plan.md 真实存在,取首个命中拼写,兼容 /home 与 /mnt/data 双视图) → enforce;",
        "type": "hardcoded_data_disk",
        "fix_suggestion": "用环境变量或 @configurable CONFIG 区登记替代写死的 /mnt 数据盘路径",
        "severity": "P1"
      },
      {
        "file": "scripts/selftest-smart-merge.sh",
        "line": 308,
        "snippet": "# [2026-09-12 R3] 相对推导替代硬编码任务 worktree 路径(原 /mnt/data/... 仅本任务成立)",
        "type": "hardcoded_data_disk",
        "fix_suggestion": "用环境变量或 @configurable CONFIG 区登记替代写死的 /mnt 数据盘路径",
        "severity": "P1"
      }
    ],
    "summary": {
      "total": 5,
      "exempted": 1
    }
  },
  "has_drift_risk": true
}

=== detect_drift plan-resume ===
{
  "skill": "/mnt/data/dev/task-planner-skill/skills/plan-resume",
  "drift_issues": [
    {
      "type": "config_not_externalized",
      "pattern": "@config.json",
      "message": "SKILL.md has no @config.json reference",
      "check": "path_patterns"
    }
  ],
  "steps_extracted": [
    {
      "order": 1,
      "title": "定位所有计划目录 [M]",
      "position": 2482
    },
    {
      "order": 2,
      "title": "提取每份计划的元数据 [M]",
      "position": 3438
    },
    {
      "order": 3,
      "title": "判断完成度(决定要不要进过期判定) [M]",
      "position": 4027
    },
    {
      "order": 4,
      "title": "三维过期判定(只对未完成项) [A]",
      "position": 4263
    },
    {
      "order": 5,
      "title": "输出报告 [M]",
      "position": 5614
    },
    {
      "order": 6,
      "title": "决策路由(v0.5:默认自主推进,不再等用户抉择) [A]",
      "position": 7362
    }
  ],
  "checks": {
    "serial_vs_parallel": [],
    "model_overrides": [],
    "path_patterns": [
      {
        "type": "config_not_externalized",
        "pattern": "@config.json",
        "message": "SKILL.md has no @config.json reference",
        "check": "path_patterns"
      }
    ],
    "agent_routing": []
  },
  "parallel_safety": {
    "standard": 76,
    "scope": "/mnt/data/dev/task-planner-skill/skills/plan-resume/scripts + /mnt/data/dev/task-planner-skill/skills/plan-resume/tools",
    "issue_count": 0,
    "issues": []
  },
  "hardcoded_paths": {
    "standard": "75-D4",
    "scope": "/mnt/data/dev/task-planner-skill/skills/plan-resume/SKILL.md + references/ + scripts/*.ts,*.sh + tools/*.ts",
    "issues": [],
    "summary": {
      "total": 0,
      "exempted": 0
    }
  },
  "has_drift_risk": true
}

=== subagent_skill_auditor task-planner ===

=== 汇总 ===
扫描文件数: 636
发现问题数: 0

=== subagent_skill_auditor plan-resume ===

=== 汇总 ===
扫描文件数: 3
发现问题数: 0

=== completeness_checker task-planner pre ===
{
  "phase": "pre",
  "skill_path": "/mnt/data/dev/task-planner-skill/skills/task-planner",
  "generated_at": "2026-11-04T16:14:06.610Z",
  "total_files": 11,
  "categories": {
    "other": [
      "install.log",
      "reference.md",
      "uninstall.sh",
      ".gitignore",
      "install.sh",
      "MIGRATION.md",
      "INSTALL.md",
      "README.md",
      "examples.md"
    ],
    "config": [
      "config.json"
    ],
    "primary": [
      "SKILL.md"
    ]
  },
  "file_details": [
    {
      "path": "install.log",
      "abs_path": "/mnt/data/dev/task-planner-skill/skills/task-planner/install.log",
      "size": 52418,
      "mtime": "2026-10-18T17:53:48.928Z",
      "sha256": "92986f2f7e645424a4a5c9f12dde1bae94d5c5eddf8deebeb767056b5a608b74",
      "category": "other"
    },
    {
      "path": "config.json",
      "abs_path": "/mnt/data/dev/task-planner-skill/skills/task-planner/config.json",
      "size": 28659,
      "mtime": "2026-11-04T15:26:13.677Z",
      "sha256": "90483cf4a42a507431fb9680e2d46bbdf2c7eb0595e23c34ad2c80a2f14807a1",
      "category": "config"
    },
    {
      "path": "reference.md",
      "abs_path": "/mnt/data/dev/task-planner-skill/skills/task-planner/reference.md",
      "size": 12954,
      "mtime": "2026-10-09T21:55:05.922Z",
      "sha256": "c589badab0b73b1c395193a76837a55d6398a478b1f70d92b39211c159095502",
      "category": "other"
    },
    {
      "path": "uninstall.sh",
      "abs_path": "/mnt/data/dev/task-planner-skill/skills/task-planner/uninstall.sh",
      "size": 2481,
      "mtime": "2026-08-29T12:29:56.069Z",
      "sha256": "ac01a603e61204b7d83687aabd124ac0b54488de4bf3f26d30539291ad2e9b70",
      "category": "other"
    },
    {
      "path": ".gitignore",
      "abs_path": "/mnt/data/dev/task-planner-skill/skills/task-planner/.gitignore",
      "size": 275,
      "mtime": "2026-08-29T12:33:39.839Z",
      "sha256": "beb0e68e98f2edf334a58c96320947da3ba074b19687c8736675399ae9ef3e5b",
      "category": "other"
    },
    {
      "path": "install.sh",
      "abs_path": "/mnt/data/dev/task-planner-skill/skills/task-planner/install.sh",
      "size": 9901,
      "mtime": "2026-10-25T16:30:08.374Z",
      "sha256": "b4465eb3ad7fff8982c9745e3d9fc3360e25fef838dc8f8fe1df4c75ed747b60",
      "category": "other"
    },
    {
      "path": "MIGRATION.md",
      "abs_path": "/mnt/data/dev/task-planner-skill/skills/task-planner/MIGRATION.md",
      "size": 6163,
      "mtime": "2026-10-25T16:30:05.032Z",
      "sha256": "63b81607fce4ca33121205e0beefc90c7df6e601b12ced9e22df0fc1a4614b1f",
      "category": "other"
    },
    {
      "path": "INSTALL.md",
      "abs_path": "/mnt/data/dev/task-planner-skill/skills/task-planner/INSTALL.md",
      "size": 11790,
      "mtime": "2026-10-25T17:11:42.844Z",
      "sha256": "102429621cb32f699dc8b8139a3958371e692414b3a18e2b3a7d0544175d9e9a",
      "category": "other"
    },
    {
      "path": "README.md",
      "abs_path": "/mnt/data/dev/task-planner-skill/skills/task-planner/README.md",
      "size": 23588,
      "mtime": "2026-11-01T20:07:01.840Z",
      "sha256": "66467e756bb73e47218bbb62556aa02a9e2b7a786bdecb7a0549ade35258266c",
      "category": "other"
    },
    {
      "path": "examples.md",
      "abs_path": "/mnt/data/dev/task-planner-skill/skills/task-planner/examples.md",
      "size": 11184,
      "mtime": "2026-10-06T04:51:12.849Z",
      "sha256": "e234b07d081046ecfc4a3edf5217d927f447d71670f786439eb3e64dec141d8a",
      "category": "other"
    },
    {
      "path": "SKILL.md",
      "abs_path": "/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md",
      "size": 46305,
      "mtime": "2026-11-04T15:25:18.706Z",
      "sha256": "ecc89fd02a7b9607f670f36164c269cb0fc71415d8a5aa4aab073fd44995d595",
      "category": "primary"
    }
  ],
  "modification_status": {},
  "reflection_answers": {}
}

=== completeness_checker plan-resume pre ===
{
  "phase": "pre",
  "skill_path": "/mnt/data/dev/task-planner-skill/skills/plan-resume",
  "generated_at": "2026-11-04T16:14:06.710Z",
  "total_files": 3,
  "categories": {
    "config": [
      "config.json"
    ],
    "other": [
      "README.md"
    ],
    "primary": [
      "SKILL.md"
    ]
  },
  "file_details": [
    {
      "path": "config.json",
      "abs_path": "/mnt/data/dev/task-planner-skill/skills/plan-resume/config.json",
      "size": 445,
      "mtime": "2026-09-06T11:01:27.420Z",
      "sha256": "11d4fa1df2028d4742d9adb5569ebdf99fd925bfe4a684c1bbdaddbad903c85d",
      "category": "config"
    },
    {
      "path": "README.md",
      "abs_path": "/mnt/data/dev/task-planner-skill/skills/plan-resume/README.md",
      "size": 2738,
      "mtime": "2026-09-06T11:01:27.425Z",
      "sha256": "3aafebd5a6b0c42c1fc58657fec849d12cb67b431c21f071f450913807779e5c",
      "category": "other"
    },
    {
      "path": "SKILL.md",
      "abs_path": "/mnt/data/dev/task-planner-skill/skills/plan-resume/SKILL.md",
      "size": 29128,
      "mtime": "2026-10-19T20:22:32.384Z",
      "sha256": "b7b6c243450bcc8c523eb958218fa332aa331ffed4a1d705dcf900e54fad1582",
      "category": "primary"
    }
  ],
  "modification_status": {},
  "reflection_answers": {}
}
