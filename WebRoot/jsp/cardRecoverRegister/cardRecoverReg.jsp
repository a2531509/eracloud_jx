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
    <title>卡片回收登记</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	var $dg;
	var $temp;
	var $grid;
	$(function() {
		//查询证件类型
		$("#certType").combobox({
			width:174,
			url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=CERT_TYPE",
			valueField:'codeValue',
			editable:false, //不可编辑状态
		    textField:'codeName',
		    panelHeight: 'auto',//自动高度适合
		    onSelect:function(node){
		 		$("#certType").val(node.text);
		 	}
		});
		//初始化查询表格
		 $dg = $("#dg");
		 $grid=$dg.datagrid({
			url : "cardService/cardRecoverRegisterAction!queryCardRecoverRegInfo.action",
			fit:true,
			pagination:true,
			pageSize:20,
			rownumbers:true,
			border:false,
			striped:true,
			singleSelect:true,
			fitColumns:true,
			scrollbarSize:0,
			//0未启用1正常2口头挂失3书面挂失9注销
			columns:[ [ {field:'ID',title : '编号',width:parseInt($(this).width()*0.01),sortable:true},
			            {field:'BOX_NO',title : '盒号',width:parseInt($(this).width()*0.01),sortable:true},
						{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width()*0.02)},
						{field:'NAME',title:'姓名',sortable:true,width:parseInt($(this).width()*0.01)},
						{field:'CARD_NO',title:'卡号',sortable:true,width:parseInt($(this).width()*0.02)},
						{field:'APPLY_DATE',title:'申领日期',sortable:true,width:parseInt($(this).width()*0.03)},
						{field:'BRANCH',title:'申领网点',sortable:true,width:parseInt($(this).width()*0.03)},
						{field:'USER_NAME',title:'申领柜员',sortable:true,width:parseInt($(this).width()*0.01)},
						{field:'INITIAL_STATUS',title:'原申领状态',sortable:true,width:parseInt($(this).width()*0.01)}
			              ]],
			toolbar:'#tb',
          	onLoadSuccess:function(data){
          		if(data.status != 0){
            		$.messager.alert('系统消息',data.errMsg,'error');
            	}
          	}
		});
	});
	//查询
	function query(){
		$dg.datagrid('load',{
			queryType:'0',//查询类型
			certTypeTemp:$("#certType").combobox('getValue'), 
			certNoTemp:$('#certNo').val(), 
			nameTemp:$("#name").val(),
			cardNoTemp:$('#cardNo').val(),
			cardRecoverId:$("#cardRecoverId").val(),
			boxNo:$("#boxNo").val()
		});
	}
	
	function toInputData(){
		$.modalDialog({
			title:'录入回收卡片数据',
			iconCls:'incon-add',
			fit:true,
			maximized:true,
			shadow:false,
			closable:false,
			maximizable:false,
			href:"/jsp/cardRecoverRegister/cardRecoverAdd.jsp",
			onDestroy:function(){
				query();
			},
			buttons:[{
					text:'保存',
					iconCls:'icon-ok',
					handler:function() {
						saveCardRecoverRegInfo();
					}
				},{
					text:'取消',
					iconCls:'icon-cancel',
					handler:function() {
						$.modalDialog.handler.dialog('destroy');
					    $.modalDialog.handler = undefined;
					}
				}
		   ]
		});
	}
</script>
</head>
<body>
 <div id="p_layout" class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="overflow: hidden; padding: 0px;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span>
			<span>在此你可以对<span class="label-info"><strong>未发放完成的卡片</strong></span>进行卡片回收操作!</span>
		</div>
	</div>
	<div id="p_layouts" data-options="region:'center',split:false,border:true" style="padding:0px;width:auto;">
			<div id="tb" style="padding:2px 0">
				<form id="searchFrom">
					<table cellpadding="0" cellspacing="0" class="tablegrid" width="100%">
						<tr>
							<td class="tableleft" style="padding:0 3px">证件类型：</td>
							<td class="tableright" style="padding:0 3px"><input id="certType" type="text" class="easyui-combobox  easyui-validatebox" name="certType" value="1" style="width:174px;cursor:pointer;"/></td>
							<td class="tableleft" style="padding:0 3px">证件号码：</td>
							<td class="tableright" style="padding:0 3px"><input name="certNo"  class="textinput" id="certNo" type="text" /></td>
							<td class="tableleft" style="padding-left:3px;">姓名：</td>
							<td class="tableright" style="padding-left:3px;"><input type="text" name="name" id="name" class="textinput"/></td>
							<td class="tableleft" style="padding:0 3px">卡号：</td>
							<td class="tableright" style="padding:0 3px"><input name="cardNo"  class="textinput" id="cardNo" type="text" /></td>
						</tr>
						<tr>
							<td class="tableleft" style="padding:0 3px">编号：</td>
							<td class="tableright" style="padding:0 3px"><input name="cardRecoverId"  class="textinput" id="cardRecoverId" type="text" /></td>
							<td class="tableleft" style="padding:0 3px">盒号：</td>
							<td class="tableright" style="padding:0 3px"><input name="boxNo"  class="textinput" id="boxNo" type="text" /></td>
							<td class="tableright" style="padding:0 3px" colspan="4">
								<shiro:hasPermission name="cardLostSave">
									<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton1" name="subbutton" onclick="query()">查询</a>
									<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-import'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton2" name="subbutton" onclick="toInputData()">录入数据</a>
								</shiro:hasPermission>
									
							</td>
						</tr>
					</table>
				</form>
			</div>
	  		<table id="dg" title="卡片回收登记信息"></table>
	  </div>
	</div>
</body>
</html>