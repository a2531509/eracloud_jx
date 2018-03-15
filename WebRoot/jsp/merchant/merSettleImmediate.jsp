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
<title>商户即时结算</title>
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	var $dg;
	$(function() {
		$dg = $("#dg");
		
		$("#merchantType").combobox({
			valueField:"id",
			textField:"typeName",
			editable:false,
			panelHeight: 'auto'
		});
		
		$.post("merchantType/merchantTypeAction!queryMerType.action",function(data){
			data.unshift({id:'',typeName:'请选择'});
			$("#merchantType").combobox("loadData",data);
		},"json");
		
		$("#merchantState").combobox({
			url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=MERCHANT_STATE",
			valueField:"codeValue",
			textField:"codeName",
			editable:false,
			panelHeight: 'auto'
		});
		
		$("#dg").datagrid({
			url : "/merchantRegister/merchantRegisterAction!merchantInfoQuery.action",
			pagination : true,
			rownumbers : true,
			border : false,
			singleSelect : true,
			fit : true,
			fitColumns : true,
			scrollbarSize : 0,
			striped : true,
			toolbar : '#tb',
			pageSize: 20,
			columns:[[
				{field : 'customerId',checkbox:true},
				{field : 'merchantId',title : '商户编号',width : parseInt($(this).width() * 0.1),sortable:true},
				{field : 'merchantName',title : '商户名称',width : parseInt($(this).width()*0.2),sortable:true},
				{field : 'typeName',title : '商户类型',width : parseInt($(this).width()*0.1)},
				{field : 'typeNo',hidden:true},
				{field : 'contact',title : '联系人',width : parseInt($(this).width()*0.1),sortable:true},
				{field : 'conPhone',title : '联系人电话', width :parseInt($(this).width()*0.1)},
				{field : 'conCertNo',title : '联系人证件号码', width :parseInt($(this).width()*0.1)},
				{field : 'merchantState',title : '状态', width :parseInt($(this).width()*0.1),formatter:function(value,row){
					if(value == '0'){
						return '正常';
					}else if(value == '1'){
						return '注销';
					}else{
						return '未审核';
					}
				}},
				{field : 'note',title : '备注',width:parseInt($(this).width()*0.2)}
			]],
			onLoadSuccess : function(data) {
				if (data.status != 0) {
					$.messager.alert('系统消息', data.errMsg, 'error');
				}
				var allch = $(':checkbox').get(0);
				if (allch) {
					allch.checked = false;
				}
			}
		});
	});
	
	function query(){
		var merType = $("#merchantType").combobox("getValue");
		
		$dg.datagrid('load',{
			queryType:'0',//查询类型
			merchantId:$("#merchantId").val(), 
			merchantName:$("#merchantName").val(), 
			merchantState:$("#merchantState").combobox("getValue"),
			merchantType:merType
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
	
	function merSettleImmediate(){
		var merchant = $("#dg").datagrid("getSelected");
		
		if(!merchant){
			$.messager.alert("消息提示", "请选择商户!", "error");
			return;
		}
		
		var merchantId = merchant.merchantId;
		
		$.ajax({
			url:"merchantSettle/merchantSettleAction!merSettleImmediate.action",
			type:"post",
			data:{
				merchantId:merchantId
			},
			dataType:"json",
			success:function(data,status){
				if(data.status=='0'){
					$.messager.alert("消息提示", "商户即时结算成功!", "info");
				}else{
					$.messager.alert("消息提示", data.errMsg, "info");
				}
			},
			error:function(){
				$.messager.alert("消息提示", "访问网络服务失败!", "error");
			}
		});
	}
	
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
	<div data-options="region:'north', border:false"
		style="height: auto; overflow: hidden;">
		<div class="well well-small datagrid-toolbar" style="margin: 2px 0;">
			<span class="badge">提示</span> <span>在此你可以对商户进行<span
				class="label-info"><strong>即时结算</strong></span>!
			</span>
		</div>
	</div>
	<div data-options="region:'center', split:false, border:true"
		style="border-bottom: none; border-left: none; height: auto; overflow: hidden;">
		<div id="tb" style="padding: 2px 0;">
			<table class="tablegrid" cellpadding="0" cellspacing="0">
				<tr>
					<td class="tableleft">商户编号：</td>
					<td class="tableright"><input type="text" name="merchantId" id="merchantId" class="textinput" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
					<td class="tableleft">商户名称：</td>
					<td class="tableright"><input type="text" name="merchantName" id="merchantName" class="textinput" onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
					<td class="tableleft">商户类型：</td>
					<td class="tableright"><input type="text" name="merchantType" id="merchantType" class="textinput"/></td>
					<td class="tableleft">商户状态：</td>
					<td class="tableright"><input type="text" name="merchantState" id="merchantState" class="textinput"/></td>
				</tr>
				<tr>
					<td class="tableright" colspan="8">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="query()">查询</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-comp" plain="false" onClick="merSettleImmediate()">商户即时结算</a>
					</td>
				</tr>
			</table>
		</div>
		<table id="dg" title="商户信息" width="100%"></table>
	</div>
</body>
</html>