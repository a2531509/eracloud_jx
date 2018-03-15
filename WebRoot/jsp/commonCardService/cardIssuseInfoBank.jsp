<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">
	var cardIssuseInfoGrid;
	$(function(){
		$cardIssuseInfoGrid = createDataGrid({
			id:"cardIssuseInfo",
			url:"cardIssuse/cardIssuseAction!oneCardIssuseQuery.action",
			pagination:false,
			fitColumns:false,
			scrollbarSize:0,
			fit:false,
			singleSelect:true,
			frozenColumns:[[
				{field:"APPLY_ID",title:"申领编号",checkbox:"ture"},
		  	    {field:"CUSTOMER_ID",title:"客户编号",sortable:true},
				{field:"NAME",title:"客户姓名",sortable:true,width : parseInt($(this).width() * 0.06)},
				{field:"CERTTYPE",title:"证件类型",sortable:true},
				{field:"CERT_NO",title:"证件号码",sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:"CARDTYPE",title:"卡类型",sortable:true,width : parseInt($(this).width() * 0.06)},
				{field:"CARD_NO",title:"卡号",sortable:true,width : parseInt($(this).width() * 0.13)},
				{field:"MAKE_BATCH_ID",title:"批次号",sortable:true,width : parseInt($(this).width() * 0.07)},
				{field:"TASK_ID",title:"任务编号",sortable:true}
			]],
		  	columns:[[
				{field:"APPLYTYPE",title:"申领类型",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"APPLYWAY",title:"申领方式",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"APPLYSTATE",title:"申领状态",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"IS_URGENT",title:"制卡方式",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"BRCH_NAME",title:"发放网点",sortable:true},
				{field:"RELS_USER_ID",title:"发放柜员",sortable:true},
				{field:"RELS_DATE",title:"发放时间",sortable:true},
				{field:"RECV_CERT_TYPE",title:"领卡代理人证件类型",sortable:true},
				{field:"RECV_CERT_NO",title:"领卡代理人证件号码",sortable:true},
				{field:"RECV_NAME",title:"领卡代理人姓名",sortable:true},
				{field:"RECV_PHONE",title:"领卡代理人联系电话",sortable:true}
		    ]],
		    onLoadSuccess:function(data){
		      	if(data.rows.length > 0){
		      		$(this).datagrid("selectRow",0);
		      	}
	        }
		});
	});
	function cardIssuseInfoQuery(){
		if(dealNull($("#personalCertNo").val()).length == 0){
			$.messager.alert("系统消息","请输入查询条件！","error");
			return;
		}
		$cardIssuseInfoGrid.datagrid("load",{
			queryType:"0",
			"person.certNo":$("#personalCertNo").val()
		});
	}
</script>
<table id="cardIssuseInfo" style="height: 100%;"></table>