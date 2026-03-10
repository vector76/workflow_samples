
START.sh                reset CLAIM.sh
CLAIM.sh                fork to DIALOG_STEP.sh or fork to GENERATE.sh with main thread back to START
    
DIALOG_STEP.sh          goto DIALOG_FIRST, NEXT, LAST, or DIALOG_FINALIZE
DIALOG_FIRST            goto DIALOG_FINALIZE
DIALOG_NEXT             goto DIALOG_FINALIZE
DIALOG_LAST             goto DIALOG_FINALIZE
DIALOG_FINALIZE.sh      result STOP (terminates worker thread)
    
GENERATE.sh             goto GENERATE_DRAFT_PLAN
GENERATE_DRAFT_PLAN     goto REVIEW_PLAN
REVIEW_PLAN             call PLAN_DID_FIX with return PLAN_AGAIN_CHOICE
    PLAN_DID_FIX        result YES or NO
PLAN_AGAIN_CHOICE.sh    goto REVIEW_PLAN if YES, otherwise reset EXPLORE_CODEBASE

EXPLORE_CODEBASE        goto REVIEW_BEADS
REVIEW_BEADS            call BEADS_DID_FIX with return BEADS_AGAIN_CHOICE
    BEADS_DID_FIX       result YES or NO
BEADS_AGAIN_CHOICE.sh   goto REVIEW_BEADS if YES, otherwise reset CREATE_BEADS
    
CREATE_BEADS            call VALIDATE with return CLEANUP
    VALIDATE            result SUCCESS or result VALIDATION FAILED
CLEANUP.sh              result $RAYMOND_RESULT (from VALIDATE)
