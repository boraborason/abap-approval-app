@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Approval Document View'
@Metadata.allowExtensions: true

@Search.searchable: true
@UI.presentationVariant: [{
  sortOrder: [{ by: 'CreatedAt', direction: #DESC }],
  visualizations: [{type: #AS_LINEITEM}]
}]

define root view entity ZI_APPROVAL_DOC
  as select from zapproval_doc
{
  @Search.defaultSearchElement: true
  @EndUserText.label: '문서번호'
  key doc_id      as DocId,
  @EndUserText.label: '제목'
      title       as Title,
  @EndUserText.label: '내용'
      content     as Content,
  @EndUserText.label: '기안자'
      requester   as Requester,
  @EndUserText.label: '상태'
  @ObjectModel.text.element: ['StatusText']
      status      as Status,
  @EndUserText.label: '기안일'
      created_at  as CreatedAt,
  @EndUserText.label: '승인자'
      approved_by as ApprovedBy,
  @EndUserText.label: '승인일'
      approved_at as ApprovedAt,
      @EndUserText.label: '상태명'
      
--  Domain에 Fixed Values 설정
-- → Data Element에 Domain 연결
-- → 테이블 컬럼에 Data Element 연결
-- → 자동으로 텍스트 변환 --원래 도메인
@UI.hidden: true
cast( case status
  when '01' then '기안'
  when '02' then '승인'
  when '03' then '반려'
  else '' end as abap.char(10) ) as StatusText
}
