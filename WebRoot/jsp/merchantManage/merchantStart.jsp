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
    <title>商户信息维护</title>
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
		function setValue(vTxt) {
	       $('#merchantId').combobox('setValue', vTxt);
	    }
		$(function() {
			 $('#merchantId').combobox({
				 url:"merchantManage/merchantManageAction!getBizName.action",
                 valueField: 'merchantId', 
                 textField: 'merchantName',
                 mode:"remote",
                 onBeforeLoad:function(params){
                	if(params && params["q"]){
                		params["objStr"] = params["q"];
                		params["q"] = undefined;
                	}
                 },
                 loadFilter:function(data){
                	 data.unshift({"merchantId":"", "merchantName":"请选择"});
                	 
                	 return data;
                 }
             });

			
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "/merchantManage/merchantManageAction!merchantInfoQuery.action",
				width : $(this).width() - 0.1,
				height : $(this).height() - 45,
				pagination:true,
				rownumbers:true,
				border:true,
				fit:true,
				singleSelect:true,
				fitColumns: true,
				scrollbarSize:0,
				striped:true,
				autoRowHeight:true,
				columns : [ [ {field : 'customerId',hidden:true},
				              {field : 'merchantId',title : '商户编号',width : parseInt($(this).width() * 0.1),sortable:true},
				              {field : 'merchantName',title : '商户名称',width : parseInt($(this).width()*0.1),sortable:true},
				              {field : 'typeName',title : '商户类型',width : parseInt($(this).width()*0.1)},
				              {field : 'typeNo',hidden:true},
				              {field : 'contact',title : '联系人',width : parseInt($(this).width()*0.1),sortable:true},
				              {field : 'conPhone',title : '联系人电话', width :parseInt($(this).width()*0.1)},
				              {field : 'conCertNo',title : '联系人证件号码', width :parseInt($(this).width()*0.1)},
				              {field : 'merchantState',title : '状态', width :parseInt($(this).width()*0.1),formatter:function(value,row){
				            	  if(value == '0'){
				            		  return "<font color=green>正常<font>";
				            	  }else if(value == '1'){
				            			return "<font color=red>注销<font>";
				            	  }else if(value == '2'){
				            		  return '待审核';
				            	  }else if(value == '3'){
				            		  return '暂停';
				            	  }else{
				            		  return '审核不通过';
				            	  }
				              }},
				              {field : 'note',title : '备注',width:parseInt($(this).width()*0.2)}
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
				merchantId:$("#merchantId").combobox('getValue'), 
				merchantState:$("#merchantState").combobox('getValue')
			});
		}
		
		function checkinfo(state){
			var row = $dg.datagrid('getSelected');
			var string = "";
			var stateName="";
			if(row){
				stateName=row.merchantState;
				if(stateName == "0"){
					string = "正常/审核通过";
				}else if(stateName == "1"){
					string = "注销";
				}else if(stateName == "2"){
					string = "待审核";
				}else if(stateName == "3"){
					string = "暂停";
				}else if(stateName == "9"){
					string = "审核不通过";
				}else{
					$.messager.alert("系统消息","传入操作类型错误！","error");
					return;
				}
				if(stateName!='3'){
					$.messager.alert("系统消息","您选择商户状态为！【"+string+"】,不能启用","error");
					return;
				}
				$.messager.confirm("系统消息","您确定要" + string +"【" + row.merchantName + "】该商户信息吗？",function(r){
					if(r){
						$.post('merchantManage/merchantManageAction!updateState.action',{"merchant.customerId":row.customerId,"queryType":state},function(data,status){
							if(status == 'success'){
								$.messager.alert("系统消息",data.msg,(data.status == 0 ? "info" : "error"),function(){
									if(data.status == "0"){
										$dg.datagrid("reload");
									}
								});
							}else{
								$.messager.alert("系统消息",string + "该商户信息发生错误：请重新进行操作！","error");
							}
						},'json');
					}
				});
			}else{
				$.messager.alert("系统消息","请选择一条记录进行操作","error");
			}
		}
			
		
	</script>
  </head>
  <body>
  <div class="easyui-layout" data-options="fit:true" >
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对入网的<span class="label-info"><strong>商户信息</strong></span>审核操作!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
			<div id="tb" style="padding:2px 0">
				<table class="tablegrid" style="width: auto;" cellpadding="0" cellspacing="0">
					<tr>
						<td class="tableleft">商户名称：</td>
						<td class="tableright"><input id="merchantId" type="text" class="easyui-combobox  easyui-validatebox" name="merchantId"  style="width:174px;cursor:pointer;"  /></td>
						<td class="tableleft">商户状态：</td>
						<td class="tableright"><select id="merchantState" class="easyui-combobox easyui-validatebox" name="merchantState" style="width:174px;" data-options="panelHeight: 'auto', editable:false"  validType="selectValueRequired['#smerchantState']">
														<option value="">请选择</option>
														<option value="0">正常</option>
														<option value="1">注销</option>
														<option value="2">待审核</option>
														<option value="3">暂停</option>
														<option value="9">审核不通过</option>
													  </select>
						</td>
						<td class="tableright">
							<a style="text-align:center;margin:0 auto;"  data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" onclick="query()">查询</a>
							<a href="javascript:void(0);" class="easyui-menubutton" iconCls="icon-checkInfo" data-options="menu:'#mm1'" plain="false" onclick="javascript:void(0)">审核管理</a>
						</td>
					</tr>
				</table>
			</div>
			<div id="mm1" style="width:50px;display: none;">
			     <div data-options="iconCls:'icon-ok'" onclick="checkinfo('0')">启用</div>
		     </div>
	  		<table id="dg" title="商户信息" style="overflow:hidden;"></table>
	  </div>
	  
	</div>
  </body>
</html>
