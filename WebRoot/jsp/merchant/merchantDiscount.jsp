<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<%@taglib uri="http://shiro.apache.org/tags"  prefix="shiro"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.merchant/TR/html4/loose.dtd">
<html>
<head>
<base href="<%=basePath%>">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>商户折扣率设置</title>
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	$(function() {
		$("#state").combobox({
			valueField:"value",
			textField:"label",
			data:[{label:"请选择",value:""},
			      {label:"待审核",value:"0"},
			      {label:"已审核",value:"1"},
			      {label:"已注销",value:"3"}],
			editable:false,
			panelHeight: 'auto'
		});
		
		$("#dg").datagrid({
			url : "merchant/merchantDiscountAction!getMerchantDiscounts.action",
			pagination : true,
			fit : true,
			toolbar : $("#tb"),
			pageSize : 20,
			striped : true,
			border : false,
			rownumbers : true,
			showFooter : true,
			fitColumns : true,
			columns : [[
				{field:"ID", checkbox:true},
				{field:"MERCHANT_ID", title:"商户编号", sortable:true, width:parseInt($(this).width()*0.08)},
				{field:"MERCHANT_NAME", title:"商户名称", sortable:true, width:parseInt($(this).width()*0.05)},
				{field:"ACC_NAME", title:"账户类型", sortable:true, width:parseInt($(this).width()*0.04)},
				{field:"DISCOUNT_TYPE", title:"折扣方式", sortable:true, width:parseInt($(this).width()*0.04)},
				{field:"DISCOUNT_TXT", title:"折扣时间", sortable:true, width:parseInt($(this).width()*0.1)},
				{field:"DISCOUNT", title:"折扣率", sortable:true, width:parseInt($(this).width()*0.04)},
				{field:"STARTDATE", title:"生效日期", sortable:true, width:parseInt($(this).width()*0.05)},
				{field:"INSERT_USER_ID", title:"创建人", sortable:true, width:parseInt($(this).width()*0.05)},
				{field:"INSERT_DATE", title:"录入日期", sortable:true, width:parseInt($(this).width()*0.08)},
				{field:"STATE", title:"状态", sortable:true, width:parseInt($(this).width()*0.04),formatter: function(value){
					if(value == "0"){
						return "<span style='color:orange'>待审核</span>";
					}else if(value == "1"){
						return "<span style='color:green'>已审核</span>";
					}else if(value == "3"){
						return "<span style='color:red'>已注销</span>";
					}
				}},
				{field:"NOTE", title:"备注", sortable:true, width:parseInt($(this).width()*0.1)}
			]],
			queryParams:{
				queryType:"1"
			},
			onLoadSuccess : function(data) {
				if (data.status == "1") {
					$.messager.alert('系统消息', "加载数据失败, " + data.errMsg, 'error');
				}
			}
		});
	})
	
	function query(){
		$("#dg").datagrid("load", {
			"merchant.merchantId":$("#merchantId").val(),
			"merchant.merchantName":$("#merchantName").val(),
			"discount.state":$("#state").combobox("getValue"),
			queryType:"1"
		});
	}
	
	function addDiscount(){
		openModalDialog2("新增商户折扣率", "icon-add", "merchant/merchantDiscountAction!addDiscountPage.action", 
				function(){save();});
	}
	
	function checkDiscount(){
		var selection = $("#dg").datagrid("getSelections");
		
		if(selection.length!=1){
			$.messager.alert('系统消息', "请选择一条记录", 'info');
			return;
		}
		
		if(selection[0].STATE=="3"){
			$.messager.alert('系统消息', "折扣已注销", 'info');
			return;
		}
		
		$.messager.confirm("消息提示","确认审核",function(r){
			if(r){
				$.post("merchant/merchantDiscountAction!checkDiscount.action",{"discount.id":selection[0].ID},function(data){
					if(data.status == "1"){
						$.messager.alert("消息提示", data.errMsg, "error");
					} else {
						$.messager.alert("消息提示", "操作成功", "info", function(){
							query();
						});
					}
				},"json");
			}
		});
	}
	
	function cancelWelfare(){
		var selection = $("#dg").datagrid("getSelections");
		
		if(selection.length!=1){
			$.messager.alert('系统消息', "请选择一条记录", 'info');
			return;
		}
		
		if(selection[0].STATE=="3"){
			$.messager.alert('系统消息', "折扣已注销", 'info');
			return;
		}
		
		$.messager.confirm("消息提示","确认撤销",function(r){
			if(r){
				$.post("merchant/merchantDiscountAction!cancelDiscount.action",{"discount.id":selection[0].ID},function(data){
					if(data.status == "1"){
						$.messager.alert("消息提示", data.errMsg, "error");
					} else {
						$.messager.alert("消息提示", "操作成功", "info", function(){
							query();
						});
					}
				},"json");
			}
		});
	}
	
	function openModalDialog(title, icon, url, saveCallback){
		$.modalDialog({
			title:title,
			iconCls:icon,
			maximized:true,
			shadow:false,
			closable:false,
			maximizable:false,
			href:url,
			onDestroy : function() {
				query();
			},
			buttons:[{text:'返回',iconCls:'icon-cancel',handler:function(){
							$.modalDialog.handler.dialog('destroy');
						    $.modalDialog.handler = undefined;
					 	}
					 }
		   ]
		});
	}
	
	function openModalDialog2(title, icon, url, saveCallback){
		$.modalDialog({
			width:"600",
			height:"300",
			title:title,
			iconCls:icon,
			shadow:false,
			closable:false,
			href:url,
			onDestroy : function() {
				query();
			},
			buttons:[{text:'保存', iconCls:'icon-ok', handler:saveCallback},
			         {text:'取消',iconCls:'icon-cancel',handler:function(){
							$.modalDialog.handler.dialog('destroy');
						    $.modalDialog.handler = undefined;
					 	}
					 }
		   ]
		});
	}
	
	
	function editDiscount(){
		var selection = $("#dg").datagrid("getSelections");
		
		if(selection.length!=1){
			$.messager.alert('系统消息', "请选择一条记录", 'info');
			return;
		}
		
		if(selection[0].STATE=="3"){
			$.messager.alert('系统消息', "折扣已注销", 'info');
			return;
		}
		
		openModalDialog2("修改商户折扣率", "icon-edit", "merchant/merchantDiscountAction!editDiscountPage.action?discount.id=" + selection[0].ID, 
				function(){save();});
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
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
	<div data-options="region:'north',border:false"
		style="overflow: hidden;">
		<div class="well well-small datagrid-toolbar" style="margin: 2px 0">
			<span class="badge">提示</span> <span>在此你可以对<span
				class="label-info"><strong>商户折扣率</strong></span>进行<span
				class="label-info"><strong>新增/审核/注销</strong>等操作</span></span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true"
		style="border-left: none; border-bottom: none; height: auto; overflow: hiddsen;">
		<div id="tb" style="padding: 2px 0">
			<table class="tablegrid" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td class="tableleft">商户编号：</td>
					<td class="tableright"><input id="merchantId"
						class="textinput" onkeydown="autoCom()" onkeyup="autoCom()" /></td>
					<td class="tableleft">商户名称：</td>
					<td class="tableright"><input id="merchantName"
						class="textinput" onkeydown="autoComByName()"
						onkeyup="autoComByName()" /></td>
					<td class="tableleft">状态：</td>
					<td class="tableright"><input id="state"
						class="textinput" />&nbsp;<a href="javascript:void(0);"
						class="easyui-linkbutton" iconCls="icon-search" onclick="query()">查询</a></td>
				</tr>
				<tr>
					<td class="tableright" colspan="6" style="padding-left: 30px;">
						<shiro:hasPermission name="addDiscount">
							<a href="javascript:void(0);" class="easyui-linkbutton"
								iconCls="icon-add" onclick="addDiscount()">新建</a>&nbsp;
						</shiro:hasPermission> <shiro:hasPermission name="modifyDiscount">
							<a href="javascript:void(0);" class="easyui-linkbutton"
								iconCls="icon-edit" onclick="editDiscount()">编辑</a>&nbsp;
						</shiro:hasPermission> <shiro:hasPermission name="checkDiscount">
							<a href="javascript:void(0);" class="easyui-linkbutton"
								iconCls="icon-checkInfo" onclick="checkDiscount()">审核</a>&nbsp;
						</shiro:hasPermission> <shiro:hasPermission name="cancelDiscount">
							<a href="javascript:void(0);" class="easyui-linkbutton"
								iconCls="icon-remove" onclick="cancelWelfare()">注销</a>
						</shiro:hasPermission>
					</td>
				</tr>
			</table>
		</div>
		<table id="dg" title="商户折扣率信息"></table>
	</div>
	<div id="win"></div>
</body>
</html>