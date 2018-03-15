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
	<script type="text/javascript">
		var $dg;
		var $temp;
		var $grid;
		var $querycerttype;
		$(function() {
			
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "merchantRegister/merchantRegisterAction!merchantInfoQuery.action",
				width : $(this).width() - 0.1,
				height : $(this).height() - 45,
				pagination:true,
				pageSize:20,
				rownumbers:true,
				border:true,
				fit:true,
				singleSelect:true,
				fitColumns: true,
				scrollbarSize:0,
				striped:true,
				autoRowHeight:true,
				frozenColumns : [ [ {field : 'customerId',checkbox:true},
						              {field : 'merchantId',title : '商户编号',width : parseInt($(this).width() * 0.1),sortable:true},
						              {field : 'merchantName',title : '商户名称',width : parseInt($(this).width()*0.1),sortable:true},
						              {field : 'STL_TYPE',title : '结算方式',width : parseInt($(this).width()*0.05),sortable:true, formatter:function(value){
						            	  if(value == "0"){
						            		  return "自己结算";
						            	  } else if(value == "1"){
						            		  return "上级结算";
						            	  }
						              }},
						              {field : 'typeName',title : '商户类型',width : parseInt($(this).width()*0.06),sortable:true},
						              {field : 'ORG_NAME',title : '所属机构',width : parseInt($(this).width()*0.1),sortable:true}
						]],
						columns:[[
						    {field : 'BIZ_REG_NO',title : '工商注册号', sortable:true},
						    {field : 'INDUS_NAME',title : '行业类型', sortable:true},
						    {field : 'BANK_NAME',title : '开户银行', sortable:true},
						    {field : 'BANK_ACC_NAME',title : '开户银行账户', sortable:true},
						    {field : 'BANK_ACC_NO',title : '开户银行账户账号', sortable:true},
						    {field : 'BANK_BRCH',title : '银行网点', sortable:true},
							{field : 'contact',title : '联系人', sortable:true},
							{field : 'conPhone',title : '联系人电话1', sortable:true},
							{field : 'ADDRESS',title : '通讯地址', sortable:true},
							{field : 'conCertNo',title : '联系人证件号码', sortable:true, hidden:true},
							{field : 'merchantState',title : '状态',sortable:true, formatter:function(value,row){
							  if(value == '0'){
								  return "<span style='color:green'>正常</span>";
							  }else if(value == '1'){
								  return "<span style='color:red'>注销</span>";
							  }else{
								  return "<span style='color:orange'>未审核</span>";
							  }
							}},
							{field : 'signDate',title : '录入时间', sortable:true},
							{field : 'signUserId',title : '录入人', sortable:true},
							{field : 'note',title : '备注',sortable:true}          
						]],
				toolbar:'#tb',
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
				merchantId:$("#merchantId1").val(),
				merchantName:$("#merchantName1").val(),
				merchantState:$("#merchantState").combobox('getValue')
			});
		}
		
		//弹窗修改
		function updRowsOpenDlg() {
			var row = $dg.datagrid('getSelected');
			if (row) {
				$.modalDialog({
					title : "编辑行业",
					fit:true,
					maximized:true,
					shadow:false,
					closable:false,
					maximizable:false,
					href : "merchantManage/merchantManageAction!toEidtMerchant.action?merchantId="+row.merchantId,		
					buttons : [ {
						text : '编辑',
						iconCls : 'icon-ok',
						handler : function() {
							$.modalDialog.openner= $grid;//因为添加成功之后，需要刷新这个treegrid，所以先预定义好
							var f = $.modalDialog.handler.find("#form");
							f.submit();
						}
					}, {
						text : '取消',
						iconCls : 'icon-cancel',
						handler : function() {
							$.modalDialog.handler.dialog('destroy');
							$.modalDialog.handler = undefined;
						}
					}
					]
				});
			}else{
				$.messager.alert("系统消息","请选择一行记录!","error");
			}
		}
		
		
		function viewMer(){
			var row = $dg.datagrid('getSelected');
			if(row){
				parent.$.modalDialog({
					title : "添加商户",
					width : 900,
					height : 500,
					resizable:true,
					href : "merchantManage/merchantManageAction!viewMerchant.action?merchantId="+row.merchantId
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
            if($("#merchantId1").val() == ""){
                $("#merchantName1").val("");
            }
            $("#merchantId1").autocomplete({
                position: {my:"left top",at:"left bottom",of:"#merchantId1"},
                source: function(request,response){
                    $.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantId":$("#merchantId1").val(),"queryType":"1"},function(data){
                        response($.map(data.rows,function(item){return {label:item.label,value:item.text}}));
                    },'json');
                },
                select: function(event,ui){
                      $('#merchantId1').val(ui.item.label);
                    $('#merchantName1').val(ui.item.value);
                    return false;
                },
                  focus:function(event,ui){
                    return false;
                  }
            }); 
        }
        function autoComByName(){
            if($("#merchantName1").val() == ""){
                $("#merchantId1").val("");
            }
            $("#merchantName1").autocomplete({
                source:function(request,response){
                    $.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantName":$("#merchantName1").val(),"queryType":"0"},function(data){
                        response($.map(data.rows,function(item){return {label:item.text,value:item.label}}));
                    },'json');
                },
                select: function(event,ui){
                    $('#merchantId1').val(ui.item.value);
                    $('#merchantName1').val(ui.item.label);
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
  <div class="easyui-layout" data-options="fit:true" >
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>商户信息</strong></span>进行变更!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
			<div id="tb" style="padding:2px 0">
				<table class="tablegrid" cellpadding="0" cellspacing="0" width="100%">
					<tr>
						<td class="tableleft">商户编号：</td>
						<td class="tableright"><input id="merchantId1" type="text" class="textinput  easyui-validatebox" name="merchantId"  onkeydown="autoCom()" onkeyup="autoCom()" style="width:174px;cursor:pointer;"  /></td>
						<td class="tableleft">商户名称：</td>
						<td class="tableright"><input type="text" name="merchantName" id="merchantName1" class="textinput" onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
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
						<td class="tableleft">
							<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
						</td>
						<td class="tableright">
						
							<shiro:hasPermission name="merchantEidt">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="updRowsOpenDlg();">变更</a>
							</shiro:hasPermission>
							<!--<shiro:hasPermission name="merchantDel">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-del" plain="false" onclick="updRowsOpenDlg();">删除</a>
							</shiro:hasPermission>-->
						</td>
					</tr>
				</table>
			</div>
	  		<table id="dg" title="用户信息" style="overflow:hidden;"></table>
	  </div>
	  
	</div>
  </body>
</html>
