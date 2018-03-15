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
<title>单位批量充值</title>
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	$(function() {
		createSysCode("corpType",{codeType:"CORP_TYPE"});
		
		createSysCode("checkFlag", {codeType:"CHK_FLAG"});
		
		createSysCode("state", {codeType:"CORP_STATE"});
		
		$("#dg").datagrid({
			url : "corpManager/corpManagerAction!queryCorpInfo.action",
			pagination : true,
			fit : true,
			toolbar : $("#tb"),
			pageSize : 20,
			striped : true,
			border : false,
			rownumbers : true,
			showFooter : true,
			fitColumns : true,
			singleSelect : true,
			frozenColumns : [ [
			    {field:"", checkbox:true},
				{field:"CUSTOMER_ID", title:"单位编号", sortable:true, minWidth : parseInt($(this).width() * 0.06)},
				{field:"CORP_NAME", title:"单位名称", sortable:true, width : parseInt($(this).width() * 0.15)},
				{field:"CORP_TYPE", title:"单位类型", sortable:true, width : parseInt($(this).width() * 0.05)},
				{field:"CONTACT", title:"联系人", sortable:true, width : parseInt($(this).width() * 0.06)},
				{field:"CON_PHONE", title:"联系人电话", sortable:true, width : parseInt($(this).width() * 0.1)},
				{field:"CORP_STATE", title:"状态", sortable:true, width : parseInt($(this).width() * 0.04), formatter : function(value){
					if(value == "0") {
						return "<span style='color:green'>正常</span>";
					} else if(value == "1") {
						return "<span style='color:red'>注销</span>";
					}
				}}
			] ],
			columns : [[
				{field:"ADDRESS", title:"地址", sortable:true},
				{field:"POST_CODE", title:"邮编", sortable:true},
				{field:"CEO_NAME", title:"单位负责人", sortable:true},
				{field:"CEO_PHONE", title:"负责人电话", sortable:true},
				{field:"LEG_NAME", title:"法人", sortable:true},
				{field:"CERT_TYPE", title:"法人证件类型", sortable:true},
				{field:"CERT_NO", title:"法人证件号码", sortable:true},
				{field:"LEG_PHONE", title:"法人联系电话", sortable:true},
				{field:"FAX_NO", title:"传真", sortable:true},
				{field:"EMAIL", title:"EMAIL", sortable:true},
				{field:"PROV_CODE", title:"省份", sortable:true},
				{field:"CITY_CODE", title:"城市", sortable:true},
				{field:"SERV_PWD_ERR_NUM", title:"服务密码错误次数", sortable:true},
				{field:"NET_PWD_ERR_NUM", title:"登录密码错误次数", sortable:true},
				{field:"OPEN_DATE", title:"创建日期", sortable:true},
				{field:"OPEN_USER_ID", title:"创建操作员", sortable:true},
				{field:"CLS_DATE", title:"注销日期", sortable:true},
				{field:"CLS_USER_ID", title:"注销操作员", sortable:true},
				{field:"MNG_USER_ID", title:"客户经理", sortable:true},
				{field:"LICEENSE_NO", title:"营业执照号", sortable:true},
				{field:"REGION_ID", title:"所在城市", sortable:true},
				{field:"AREA_CODE", title:"区域", sortable:true},
				{field:"P_CUSTOMER_ID", title:"父级单位", sortable:true},
				{field:"COMPANYID", title:"社保单位", sortable:true},
				{field:"CARREF_FLAG", title:"是否车改单位", sortable:true, formatter : function(value) {
					return value == "0"?"是":"否";
				}},
				{field:"CHK_FLAG", title:"审核标志", sortable:true, formatter : function(value) {
					if(value == "0") {
						return "<span style='color:yellow'>未审核</span>";
					} else if(value == "1") {
						return "<span style='color:green'>已审核</span>";
					} else if(value == "2") {
						return "<span style='color:red'>审核不通过</span>";
					}
				}},
				{field:"CHK_DATE", title:"审核日期", sortable:true},
				{field:"CHK_USER_ID", title:"审核人", sortable:true},
				{field:"NOTE", title:"备注", sortable:true}
			]],
			onLoadSuccess : function(data) {
				if (data.status != "0") {
					$.messager.alert('系统消息', data.errMsg, 'error');
				}
			}
		});
	})

	function query() {
		$("#dg").datagrid("load", {
			customerId : $("#customerId").val(),
			corpName : $("#corpName").val(),
			corpType : $("#corpType").combobox("getValue"),
			checkFlag : $("#checkFlag").combobox("getValue"),
			state : $("#state").combobox("getValue"),
			queryType : "0"
		});
	}
	
	function autoCom(){
        if($("#customerId").val() == ""){
            $("#corpName").val("");
        }
        $("#customerId").autocomplete({
            source: function(request,response){
                $.post('corpManager/corpManagerAction!initAutoComplete.action',{"customerId":$("#customerId").val()},function(data){
                    response($.map(data.rows,function(item){return {label:item.LABEL,value:item.TEXT}}));
                },'json');
            },
            select: function(event,ui){
                $('#customerId').val(ui.item.label);
                $('#corpName').val(ui.item.value);
                return false;
            },
              focus:function(event,ui){
                return false;
              }
        }); 
    }
	
	function autoComByName(){
        if($("#corpName").val() == ""){
            $("#customerId").val("");
        }
        $("#corpName").autocomplete({
            source:function(request,response){
                $.post('corpManager/corpManagerAction!initAutoComplete.action',{"corpName":$("#corpName").val()},function(data){
                    response($.map(data.rows,function(item){return {label:item.TEXT,value:item.LABEL}}));
                },'json');
            },
            select: function(event,ui){
                $('#customerId').val(ui.item.value);
                $('#corpName').val(ui.item.label);
                return false;
            },
            focus: function(event,ui){
                return false;
            }
        }); 
    }
	
	function openModalDialog(title, icon, url, saveCallback){
		$.modalDialog({
			title:title,
			iconCls:icon,
			fit:true,
			maximized:true,
			shadow:false,
			closable:false,
			maximizable:false,
			href:url,
			buttons:[{text:'保存',iconCls:'icon-ok',handler:saveCallback},
			         {text:'取消',iconCls:'icon-cancel',handler:function(){
							$.modalDialog.handler.dialog('destroy');
						    $.modalDialog.handler = undefined;
					 	}
					 }
		   ]
		});
	}
	
	function corpBatchRecharge(){
		var selection = $("#dg").datagrid("getSelections");
		
		if(selection.length != 1) {
			$.messager.alert("消息提示", "请选择一个单位", "info");
			return;
		}
		
		$.modalDialog({
			title:'单位批量充值数据',
			iconCls:'icon-import',
			fit:true,
			maximized:true,
			border:false,
			shadow:false,
			closable:false,
			maximizable:false,
			href:"/jsp/corp/importCorpBatchRechargeInfo.jsp?customerId=" + selection[0].CUSTOMER_ID,
			buttons:[{
					text:'返回',
					iconCls:'icon-cancel',
					handler:function() {
						$.modalDialog.handler.dialog('destroy');
					    $.modalDialog.handler = undefined;
					}
				}
		   ]
		});

	}
	
	function modalWindow(title, url) {
		$('#modal').window({
			width:850,    
		    height:450,
		    modal:true,
			title:title,
		    href:url,
		    collapsible:false,
		    minimizable:false,
		    maximizable:false,
		    onClose:function(){
		    	queryCorpBatchRechargeInfo();
		    }
		});
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
	<div data-options="region:'north',border:false"
		style="overflow: hidden;">
		<div class="well well-small datagrid-toolbar" style="margin: 2px 0">
			<span class="badge">提示</span> <span>在此你可以对单位员工<span
				class="label-info"><strong>联机账户</strong></span>进行<span
				class="label-info"><strong>批量充值</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true"
		style="border-left: none; border-bottom: none; height: auto; overflow: hiddsen;">
		<div id="tb" style="padding: 2px 0">
			<table class="tablegrid" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td class="tableleft">单位编号：</td>
					<td class="tableright"><input id="customerId"
						class="textinput" onkeyup="autoCom()" onkeydown="autoCom()"/></td>
					<td class="tableleft">单位名称：</td>
					<td class="tableright"><input id="corpName" class="textinput" onkeyup="autoComByName()" onkeydown="autoComByName()"/></td>
					<td class="tableleft">单位类型：</td>
					<td class="tableright"><input id="corpType" class="textinput" /></td>
				</tr>
				<tr>
					<td class="tableleft">审核标志：</td>
					<td class="tableright"><input id="checkFlag" class="textinput" /></td>
					<td class="tableleft">状态：</td>
					<td class="tableright"><input id="state" class="textinput" /></td>
					<td class="tableright" colspan="2" style="padding-left: 15px;"><a
						href="javascript:void(0);" class="easyui-linkbutton"
						iconCls="icon-search" onclick="query()">查询</a> <a
						href="javascript:void(0);" class="easyui-linkbutton"
						iconCls="icon-rechgCard" onclick="corpBatchRecharge()">人员批量充值</a></td>
				</tr>
			</table>
		</div>
		<table id="dg" title="单位信息"></table>
	</div>
	<div id="modal"></div>
</body>
</html>