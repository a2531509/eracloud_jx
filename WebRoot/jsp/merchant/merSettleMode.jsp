<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>商户结算模式管理</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<style type="text/css">
	.tablegrid td{
		padding: 0 15px;
	}
	</style>
	<script type="text/javascript">
		var $dg;
		var $temp;
		var $grid;
		$(function() {
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "/merchantRegister/merchantRegisterAction!queryMerModeInfo.action",
				pagination:true,
				rownumbers:true,
				border:false,
				fit:true,
				singleSelect:true,
				striped:true,
				fitColumns: true,
				scrollbarSize:0,
				autoRowHeight:true,
				columns : [ [ 
				              {field : 'merchantName',title : '商户名称',width : parseInt($(this).width() * 0.1)},
				              {field : 'validDate',title : '生效日期',width : parseInt($(this).width() * 0.1)},
				              {field : 'stlMode',title : '结算模式',width : parseInt($(this).width()*0.1),formatter:function(value,row){
				            	  if(value == '1'){
				            		  return '全部扎差';
				            	  }else if(value == '2'){
				            		  return '全部不扎差';
				            	  }else if(value == '3'){
				            		  return '消费退货扎差';
				            	  }else if(value == '4'){
				            		  return '消费手续费扎差';
				            	  }else{
				            		  return '未审核';
				            	  }
				              }},
				              {field : 'stlWay',title : '本金结算方式',width : parseInt($(this).width()*0.06)},
				              {field : 'stlDays',title : '本金结算周期',width : parseInt($(this).width()*0.06)},
				              {field : 'stlLim',title : '本金结算限额',width : parseInt($(this).width()*0.06)},
				              {field : 'stlWayRet',title : '退货结算方式',width : parseInt($(this).width()*0.06)},
				              {field : 'stlDaysRet',title : '退货结算周期',width : parseInt($(this).width()*0.06)},
				              {field : 'stlLimRet',title : '退货结算限额',width : parseInt($(this).width()*0.06)},
				              {field : 'stlWayFee',title : '服务费结算方式',width : parseInt($(this).width()*0.1)},
				              {field : 'stlDaysFee',title : '服务费结算周期',width : parseInt($(this).width()*0.1)},
				              {field : 'stlLimFee',title : '服务费结算限额',width : parseInt($(this).width()*0.1)}
				              ]],toolbar:'#tb',
				              onLoadSuccess:function(data){
				            	  if(data.status != 0){
				            		 $.messager.alert('系统消息',data.errMsg,'error');
				            	  }
				              }
			});
		});
		function query(){
			$dg.datagrid('load',{
				queryType:'0',//查询类型
				merchantId:$("#merchantId").val()
			});
		}
		
		//弹窗修改
		function updRowsOpenDlg() {
			var row = $dg.datagrid('getSelected');
			if (row) {
				parent.$.modalDialog({
					title : "编辑商户消费控制参数",
					width : 980,
					height : 400,
					href : "/merchantRegister/merchantRegisterAction!toEidtMerSettleMode.action?merchantId="+row.merchantId+"&validDate="+row.validDate,
					buttons : [ {
						text : '编辑',
						iconCls : 'icon-ok',
						handler : function() {
							parent.$.modalDialog.openner= $grid;//因为添加成功之后，需要刷新这个treegrid，所以先预定义好
							var f = parent.$.modalDialog.handler.find("#form");
							f.submit();
						}
					}, {
						text : '取消',
						iconCls : 'icon-cancel',
						handler : function() {
							parent.$.modalDialog.handler.dialog('destroy');
							parent.$.modalDialog.handler = undefined;
						}
					}
					]
				});
			}else{
				parent.$.messager.show({
					title :"提示",
					msg :"请选择一行记录!",
					timeout : 1000 * 2
				});
			}
		}
		
		function delRow(){
			var row = $dg.datagrid('getSelected');
			if (row) {
				parent.$.messager.confirm("提示","确定要删除记录吗?",function(r){  
				    if (r){  
						$.post("/merchantRegister/merchantRegisterAction!delMerMode.action",{merchantId:row.merchantId,validDate:row.validDate},function(rsp) {
							if(rsp.status){
								$dg.datagrid('reload',{
									queryType:'0'}//查询类型
								);
							}
							parent.$.messager.show({
								title : rsp.title,
								msg : rsp.message,
								timeout : 1000 * 2
							});
						}, "JSON").error(function() {
							parent.$.messager.show({
								title :"提示",
								msg :"提交错误了！",
								timeout : 1000 * 2
							});
						});
				    }  
				});
			}else{
				parent.$.messager.show({
					title :"提示",
					msg :"请选择一行记录!",
					timeout : 1000 * 2
				});
			}
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
	        $(document).keydown(function (event){ 
	            if(event.keyCode == 112){
	                basePersonalinfoquery();
	                event.preventDefault(); 
	            }else if(event.keyCode == 115){
	                addOrEditBasePersonal("1");
	                event.preventDefault(); 
	            }else{
	                return true;
	            }
	        });
	</script>
	
  </head>
  <body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>商户信息</strong></span>进行相应操作!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="border-left:none;border-bottom:none;height:auto;overflow:hidden;">
			<div id="tb" style="padding:2px 0">
				<table cellpadding="0" cellspacing="0" style="width: auto;" class="tablegrid">
					<tr>
						<td class="tableleft">商户编号：</td>
						<td class="tableright"><input type="text" name="merchantId" id="merchantId" class="textinput" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
						<td class="tableleft">商户名称：</td>
						<td class="tableright"><input type="text" name="merchantName" id="merchantName" class="textinput" onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
						<td class="tableright">
							<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							<shiro:hasPermission name="merSettleModeEdit">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit"  plain="false" onclick="updRowsOpenDlg();">编辑</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="merSettleModeDel">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove" plain="false" onclick="delRow();">删除</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</div>
	  		<table id="dg" title="结算模式信息"></table>
	  </div>
  </body>
</html>
