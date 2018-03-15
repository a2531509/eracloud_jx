<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<base href="<%=basePath%>">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>清分汇总查询</title>
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	$(function() {
		createSysCode("cardType", {codeType:"CARD_TYPE"});
		
		/* createSysCode("accKind", {codeType:"ACC_KIND", codeValue:"01,02,20,21,22"}); */
		$("#accKind").combobox({
				width:174,
				url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=ACC_KIND",
				valueField:'codeValue',
				editable:false, //不可编辑状态
			    textField:'codeName',
			    panelHeight: 'auto',//自动高度适合
			    loadFilter:function(data){
					if(data.status != "0"){
						/* $.messager.alert("系统消息",data.msg,"warning"); */
					}
					return data.rows;
				},
			    onSelect:function(node){
		    		$("#accKind").val(node.codeValue);
			 	}
		});
		
		$("#dg").datagrid({
			url : "clrDeal/clrDealAction!merClrSumQuery.action",
			pagination : true,
			toolbar : $("#tb"),
			striped : true,
			rownumbers : true,
			pageSize : 20,
			fit : true,
			showFooter : true,
			border:false,
			frozenColumns : [ [
				{field:"ID",checkbox:true},
				{field:"CLR_NO",title:"清分序号",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"CLR_DATE",title:"清分日期",sortable:true,width:parseInt($(this).width()*0.07)},
				{field:"MERCHANT_ID",title:"商户编号",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"MERCHANT_NAME",title:"商户名称",sortable:true,width:parseInt($(this).width()*0.07)},
				{field:"DEAL_NAME",title:"交易名称",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"CARD_TYPE",title:"卡类型",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"ACC_KIND",title:"账户种类",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"DEAL_NUM",title:"交易笔数",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"DEAL_AMT",title:"交易金额",sortable:true,width:parseInt($(this).width()*0.06), formatter:function(value){
					return $.foramtMoney(value);
				}}
			] ],
			columns : [ [
				{field:"STL_SUM_NO",title:"消费结算汇总序号",sortable:true,width:parseInt($(this).width()*0.12)},
				{field:"STL_DATE",title:"消费结算日期",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"FEE_STL_SUM_NO",title:"手续费结算汇总序号",sortable:true,width:parseInt($(this).width()*0.12)},
				{field:"FEE_STL_DATE",title:"手续费结算汇总日期",sortable:true,width:parseInt($(this).width()*0.12)},
				{field:"STL_FLAG",title:"消费结算标志",sortable:true,width:parseInt($(this).width()*0.1),formatter:function(value,row){
					if(value == '0'){
						return '是';
					}else if(value == '1'){
						return '否';
					}
				}},
				{field:"FEE_STL_FLAG",title:"手续费结算标志",sortable:true,width:parseInt($(this).width()*0.1),formatter:function(value,row){
					if(value == '0'){
						return '是';
					}else if(value == '1'){
						return '否';
					}
				}}
			] ],
			onLoadSuccess : function(data) {
				if (data.status != "0") {
					$.messager.alert('系统消息', data.errMsg, 'error');
				}
			},
			onSelect : function(index, row) {
				count();
			},
			onSelectAll : function(rows) {
				count();
			},
			onUnselect : function(index, row) {
				count();
			},
			onUnselectAll : function(rows) {
				count();
			}
 		});
	});
	
	function query() {
		$("#dg").datagrid("load", {
			queryType:"0",
			merchantId:$("#merchantId").val(),
			merchantName:$("#merchantName").val(),
			clrDate:$("#clrDate").val(),
			cardType:$("#cardType").combobox("getValue"),
			accKind:$("#accKind").combobox('getValue')
		});
	}
	
	function autoCom(){
        if($("#merchantId").val() == ""){
            $("#merchantName").val("");
        }
        $("#merchantId").autocomplete({
            position: {my:"left top",at:"left bottom",of:"#merchantId"},
            source: function(request,response){
                $.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantId":$("#merchantId").val(),"queryType":"1"},function(data){
                    response($.map(data.rows,function(item){return {label:item.label,value:item.text}}));
                },'json');
            },
            select: function(event,ui){
                  $('#merchantId').val(ui.item.label);
                $('#merchantName').val(ui.item.value);
                return false;
            },
              focus:function(event,ui){
                return false;
              }
        }); 
    }
	
	function autoComByName(){
        if($("#merchantName").val() == ""){
            $("#merchantId").val("");
        }
        $("#merchantName").autocomplete({
            source:function(request,response){
                $.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantName":$("#merchantName").val(),"queryType":"0"},function(data){
                    response($.map(data.rows,function(item){return {label:item.text,value:item.label}}));
                },'json');
            },
            select: function(event,ui){
                $('#merchantId').val(ui.item.value);
                $('#merchantName').val(ui.item.label);
                return false;
            },
            focus: function(event,ui){
                return false;
            }
        }); 
    }
	
	function count(){
		var datas = $("#dg").datagrid("getSelections");
		
		var count = 0;
		var sumAmt = 0.00;
		
		for(var i in datas){
			count += parseFloat(datas[i].DEAL_NUM);
			sumAmt += parseFloat(datas[i].DEAL_AMT);
		}
		
		$("#dg").datagrid("reloadFooter", [
			{CLR_NO:"统计：",CARD_TYPE:"交易笔数：", ACC_KIND:count, DEAL_NUM:"交易金额：", DEAL_AMT:sumAmt.toFixed(2)}
		]);
	}
</script>
</head>
<body class="easyui-layout" data-optoins="fit:true">
	<div data-options="region:'north',border:false"
		style="overflow: hidden;">
		<div class="well well-small datagrid-toolbar" style="margin: 2px 0;">
			<span class="badge">提示</span> <span>在此可以查询<span
				class="label-info"><strong>商户清分汇总</strong></span>信息
			</span>
		</div>
	</div>
	<div data-options="region:'center', split:false, border: true"
		style="border-left: none; border-bottom: none; height: auto; overflow: hidden;">
		<div id="tb" style="padding: 2px 0;">
			<table class="tablegrid" width="100%">
				<tr>
					<td class="tableleft" style="padding: 0 3px;">商户编号：</td>
					<td class="tableright" style="padding: 0 3px;"><input
						id="merchantId" class="textinput" onkeyup="autoCom()" onkeydown="autoCom()"></td>
					<td class="tableleft" style="padding: 0 3px;">商户名称：</td>
					<td class="tableright" style="padding: 0 3px;"><input
						id="merchantName" class="textinput" onkeyup="autoComByName()" onkeydown="autoComByName()"></td>
					<td class="tableleft" style="padding: 0 3px;">清分日期：</td>
					<td class="tableright" style="padding: 0 3px;"><input
						id="clrDate" class="textinput Wdate"
						onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"
						readonly="true"></td>
				</tr>
				<tr>
					<td class="tableleft" style="padding: 0 3px;">卡类型：</td>
					<td class="tableright" style="padding: 0 3px;"><input
						id="cardType" class="textinput"></td>
					<td class="tableleft" style="padding: 0 3px;">账户类型：</td>
					<td class="tableright" style="padding: 0 3px;"><input
						id="accKind" class="textinput"></td>
					<td class="tableright" style="padding-left: 20px;" colspan="2"><a
						class="easyui-linkbutton" iconCls="icon-search"
						href="javascript:void(0);" onclick="query()" plain="false">查询</a></td>
				</tr>
			</table>
		</div>
		<table id="dg" title="商户清分汇总信息"></table>
	</div>
</body>
</html>