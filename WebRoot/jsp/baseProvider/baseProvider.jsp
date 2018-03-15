<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $temp;
	var $grid;
	$(function(){
		createLocalDataSelect({
			id:"providerState",
			data:[{value:"",text:"请选择"},{value:"0",text:"使用中"},{value:"1",text:"已注销"}]
		});
		createLocalDataSelect({
			id:"providerType",
			data:[{value:"",text:"请选择"},{value:"1",text:"POS机具供应商"},{value:"2",text:"读写卡机具供应商"},{value:"3",text:"PSAM卡供应商"}]
		});
		$grid = createDataGrid({
			id:"dg",
			url:"BaseProvider/baseProviderAction!queryBaseProvider.action",
			pagination:true,
			rownumbers:true,
			border:false,
			fit:true,
			singleSelect:true,
			checkOnSelect:true,
			striped:true,
			autoRowHeight:true,
			scrollbarSize:0,
			fitColumns:true,
			columns:[[   
                {field:'PROVIDER_ID',title:'id',sortable:true,checkbox:'true'},
				{field:'PROVIDER_NAME',title:'供应商名称',sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:'PROVIDER_CONTRACT',title:'合同时段',sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:'PROVIDER_TYPE',title:'供应类型',sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:'PROVIDER_LINKMAN',title:'联系人',sortable:true,width : parseInt($(this).width() * 0.06)},
				{field:'PROVIDER_TEL_NO',title:'联系电话',sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:'PROVIDER_ADDRESS',title:'联系地址',sortable:true,width : parseInt($(this).width() * 0.15)},
				{field:'PROVIDER_POST',title:'供应商邮编',sortable:true,width : parseInt($(this).width() * 0.06)},
				{field:'OPER_DATE',title:'操作时间',sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:'PROVIDER_STATE',title:'启用状态',sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:'OPER_ID',title:'操作人',sortable:true}
			]]
		});
	});
	function query(){
		var c = getformdata("searchCont");
		$grid.datagrid("load",c);			
	}
	function updRowsOpenDlg() {
		var rows = $grid.datagrid('getChecked');
		if (rows.length == 1) {
			parent.$.modalDialog({
				title:"编辑供应商信息",
				width:870,
				height:500,
				href:"BaseProvider/baseProviderAction!toEditBaseProvider.action?providerId="+rows[0].PROVIDER_ID,
				buttons:[ 
				    {
						text:'编辑',
						iconCls:'icon-ok',
						handler:function() {
							
							parent.$.modalDialog.openner= $grid;//因为添加成功之后，需要刷新这个treegrid，所以先预定义好
							var f = parent.$.modalDialog.handler.find("#form");							
							f.submit();
						}
					}, 
					{
						text:'取消',
						iconCls:'icon-cancel',
						handler:function() {
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
	function addRowsOpenDlg() {
		var row = $grid.datagrid('getSelected');
		parent.$.modalDialog({
			title:"新增供应商信息",
			width:870,
			height:500,
			resizable:true,
			href:"BaseProvider/baseProviderAction!toAddBaseProvider.action",
			buttons:[ 
			    {
					text:'保存',
					iconCls:'icon-ok',
					handler:function() {
						parent.$.modalDialog.openner = $grid;
						var f = parent.$.modalDialog.handler.find("#form");
						f.submit();
					}
				}, 
				{
					text:'取消',
					iconCls:'icon-cancel',
					handler:function() {
						parent.$.modalDialog.handler.dialog('destroy');
						parent.$.modalDialog.handler = undefined;
					}
				}
			]
		});
	}
	function delRowsOpenDlg(){
		var currow = $grid.datagrid("getSelected");
		if(currow){
			$.messager.confirm("系统消息","您确定要删除账供应商【" + currow.PROVIDER_NAME + "】吗？",function(r){
				if(r){
					$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
					$.post("/BaseProvider/baseProviderAction!deleteBaseProvider.action",{providerId:currow.PROVIDER_ID},function(data,status){
						$.messager.progress('close');
						$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function() {
							if(data.status == "0"){
								$grid.datagrid("reload");
							}
						});
					},"json");
				}
			});
		}else{
			$.messager.alert("系统消息","请选择一行记录信息在进行操作！","error");
		}
	}
</script>
<n:initpage title="供应商信息进行管理！">
	<n:center>
		<div id="tb" >
			<form id="searchCont">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">供应商名称：</td>
						<td class="tableright"><input type="text" name="providerName" id="providerName" class="textinput" maxlength="50" onkeydown="autoCom()" onkeyup="autoCom()" /></td>
						<td class="tableleft">供应商状态：</td>
						<td class="tableright"><input id="providerState" name="providerState" type="text" class="textinput"/></td>
						<td class="tableleft">供应商类型：</td>
						<td class="tableright"><input id="providerType" name="providerType" type="text" class="textinput"/></td>
						<td class="tableright">
							<a data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<shiro:hasPermission name="terminalAdd">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add"  plain="false" onclick="addRowsOpenDlg();">添加</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="terminalEidt">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="updRowsOpenDlg();">编辑</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="terminalCancel">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove"  plain="false" onclick="delRowsOpenDlg();">删除</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
				</form>
			</div>
	  		<table id="dg" title="供应商信息"></table>
	  	</div>
	</n:center>
</n:initpage>