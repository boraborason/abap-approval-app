CLASS lhc_ApprovalDoc DEFINITION INHERITING FROM cl_abap_behavior_handler. " INHERITING =>  extends (추상클래스 개념)
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ApprovalDoc
      RESULT result.
    METHODS approve FOR MODIFY
      IMPORTING keys FOR ACTION ApprovalDoc~approve "ApprovalDoc의 approve 액션을 구현하는 메서드야"  (Behavior Definition에 action approve선언)
      RESULT result.
    METHODS reject FOR MODIFY
      IMPORTING keys FOR ACTION ApprovalDoc~reject
      RESULT result.
    METHODS set_defaults FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ApprovalDoc~set_defaults.
ENDCLASS.

CLASS lhc_ApprovalDoc IMPLEMENTATION.
  METHOD get_instance_authorizations.
    " 현재 문서의 기안자와 상태값 조회
    READ ENTITIES OF zi_approval_doc IN LOCAL MODE
      ENTITY ApprovalDoc
        FIELDS ( Requester Status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_doc).

    " 문서별 권한 체크
    LOOP AT lt_doc INTO DATA(ls_doc).
      " 기안자 본인이고 기안(01) 상태일 때만 수정/삭제 허용
      IF ls_doc-Requester = sy-uname AND ls_doc-Status = '01'.
        APPEND VALUE #(
          %tky    = ls_doc-%tky
          %update = if_abap_behv=>auth-allowed
          %delete = if_abap_behv=>auth-allowed
        ) TO result.
      ELSE.
        " 기안자 본인이 아니거나 승인/반려된 경우 불가
        APPEND VALUE #(
          %tky    = ls_doc-%tky
          %update = if_abap_behv=>auth-unauthorized
          %delete = if_abap_behv=>auth-unauthorized
        ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD approve.
    " 상태를 승인(02)으로 변경, 승인자/승인일 자동 입력
    MODIFY ENTITIES OF zi_approval_doc IN LOCAL MODE
      ENTITY ApprovalDoc
        UPDATE FIELDS ( Status ApprovedBy ApprovedAt )
        WITH VALUE #( FOR key IN keys (
          %tky       = key-%tky
          Status     = '02'
          ApprovedBy = sy-uname
          ApprovedAt = sy-datum
        ) ).
    READ ENTITIES OF zi_approval_doc IN LOCAL MODE
      ENTITY ApprovalDoc ALL FIELDS WITH
      CORRESPONDING #( keys )
      RESULT DATA(lt_result).
    result = VALUE #( FOR doc IN lt_result (
      %tky   = doc-%tky
      %param = doc
    ) ).
  ENDMETHOD.

  METHOD reject.
    " 상태를 반려(03)로 변경
    MODIFY ENTITIES OF zi_approval_doc IN LOCAL MODE
      ENTITY ApprovalDoc
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN keys (
          %tky   = key-%tky
          Status = '03'
        ) ).
    READ ENTITIES OF zi_approval_doc IN LOCAL MODE
      ENTITY ApprovalDoc ALL FIELDS WITH
      CORRESPONDING #( keys )
      RESULT DATA(lt_result).
    result = VALUE #( FOR doc IN lt_result (
      %tky   = doc-%tky
      %param = doc
    ) ).
  ENDMETHOD.

  METHOD set_defaults.
  " 생성 시 기안자, 상태 자동 입력
  MODIFY ENTITIES OF zi_approval_doc IN LOCAL MODE
    ENTITY ApprovalDoc
      UPDATE FIELDS ( Requester Status CreatedAt )
      WITH VALUE #( FOR key IN keys (
        %tky      = key-%tky
        Requester = sy-uname
        Status    = '01'
        CreatedAt = sy-datum
      ) ).
ENDMETHOD.
ENDCLASS.
