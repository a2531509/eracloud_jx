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
    <title>商户限额设置</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<style type="text/css">
		table.tablegrid td{
			padding: 0 15px;
		}
	</style>
	<script type="text/javascript">
		var $dg;
		var $temp;
		var $grid;
		var $querycerttype;
		$(function() {
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "/merchantRegister/merchantRegisterAction!merchantLmtInfoQuery.action",
				width : $(this).width() - 0.1,
				height : $(this).height() - 45,
				pagination:true,
				rownumbers:true,
				border:true,
				fit:true,
				fitColumns: true,
				scrollbarSize:0,
				singleSelect:true,
				striped:true,
				autoRowHeight:true,
				columns : [ [ 
				              {field : 'merchantId',title : '商户编号',width : parseInt($(this).width() * 0.15)},
				              {field : 'merchantName',title : '商户名称',width : parseInt($(this).width() * 0.2)},
				              {field : 'lim01',title : '单笔限额',width : parseInt($(this).width()*0.15)},
				              {field : 'lim02',title : '日累计笔数限制',width : parseInt($(this).width()*0.15)},
				              {field : 'lim03',title : '日累计金额限制',width : parseInt($(this).width()*0.15)},
				              {field : 'lim04',title : '大额消费界定', width :parseInt($(this).width()*0.15)},
				              {field : 'lim05',title : '超过大额报警笔数', width :parseInt($(this).width()*0.22)}
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
					width : 730,
					height : 300,
					href : "merchantRegister/merchantRegisterAction!toEidtMerchantLmt.action?merchantId="+row.merchantId,
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
		//弹窗增加
		function addRowsOpenDlg() {
			parent.$.modalDialog({
				title : "添加商户消费控制参数",
				width : 730,
				height : 300,
				href : "merchantRegister/merchantRegisterAction!toAddMerchantLmt.action",
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
  <body>
  <div class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>商户消费限制参数</strong></span>进行相应操作!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
			<div id="tb" style="padding:2px 0">
				<table class="tablegrid" style="width: auto;" cellpadding="0" cellspacing="0">
					<tr>
						<td class="tableleft">商户编号：</td>
						<td class="tableright"><input id="merchantId" type="text" class="textinput  easyui-validatebox" name="merchantId"  onkeydown="autoCom()" onkeyup="autoCom()" style="width:174px;cursor:pointer;"  /></td>
						<td class="tableleft">商户名称：</td>
						<td class="tableright"><input type="text" name="merchantName" id="merchantName" class="textinput" onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
						<td class="tableleft">
							<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
						</td>
						<td class="tableright">
							<shiro:hasPermission name="merchantLmtAdd">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add"  plain="false" onclick="addRowsOpenDlg();">添加</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="merchantLmtEidt">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="updRowsOpenDlg();">编辑</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</div>
	  		<table id="dg" title="用户信息"></table>
	  </div>
	  
	</div>
  </body>
</html>
