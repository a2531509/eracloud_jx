<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $grid;
	$(function() {
		$.createCustomSelect({
			id:"brchName",
			value:"sysbranch_id",
			text:"full_name",
			table:"sys_branch",
			isShowDefaultOption:true,
			orderby:"brch_id asc",
			from:1,
			to:1000,
			editable:true
		})
		$dg = $("#dg");
		$grid = $dg.treegrid({
			id:"dg",
			url:"orgz/SysBranchAction!findSysBranchListTreeGrid.action",
			rownumbers:true,
			animate:true,
			collapsible:false,
			fitColumns:true,
			fit:true,
			scrollbarSize:0,
			striped:true,
			border:false,
			singleSelect:true,
			idField:"sysBranchId",
			treeField:"fullName",
			frozenColumns:[[
                {title:"网点名称",field:"fullName",width:parseInt($(this).width() * 0.2),
                   	formatter:function(value){
                    	return '<span style="color:purple">' + value + '</span>';
                    }
                }
			]],
			columns:[[ 
			    {field : "sysBranchId",title : "id",hidden:true},
              	{field : "brchId",title : "网点编码",width : parseInt($(this).width()*0.1)},
              	{field : "orgId",title : "所属机构",width : parseInt($(this).width()*0.1),align : "left"},
              	{field : "shortName",title : "简称",width : parseInt($(this).width()*0.1),align : "left"},
              	{field : "iconCls",title : "组织图标",align : "center",width : parseInt($(this).width()*0.1),
            	  	formatter:function(value,row){
            		  	return "<span class='"+row.iconCls+"' style='display:inline-block;vertical-align:middle;width:16px;height:16px;'></span>";
					}},
              	{field : "tel",title : "电话",width : parseInt($(this).width()*0.1),align : "left"},
              	{field : "fax",title : "传真",width : parseInt($(this).width()*0.1),align : "left"},
              	{field : "description",title : "程式描述",hidden:true,width : parseInt($(this).width()*0.15),align:"left"},
              	{field : "brchAddress",title : "网点地址",width : parseInt($(this).width()*0.1)}
            ]],toolbar:"#tb"
		});
	});
	function delRows(){
		var node = $dg.treegrid("getSelected");
		if(node){
			parent.$.messager.confirm("系统消息","您确定要注销勾选的网点吗?",function(r){  
			    if (r){  
					$.post("orgz/SysBranchAction!delSysBranch.action", {id:node.sysBranchId}, function(rsp) {
						if(rsp.status){
							$dg.treegrid("remove", node.sysBranchId);
						}
						jAlert(rsp.message,"info");
					}, "JSON").error(function() {
						jAlert("出错了","error");
					});
			    }  
			});
		}else{
			jAlert("请选择一行记录！","warning");
		}
	}
	function updRowsOpenDlg() {
		var row = $dg.treegrid("getSelected");
		if (row) {
			$.modalDialog({
				iconCls:"icon-edit",
				title:"编辑网点",
				fit:true,
				maximized:true,
				closable:false,
				href : "jsp/organization/organizationEditDlg.jsp",
				onLoad:function(){
					var f = $.modalDialog.handler.find("#form");
					f.form("load", row);
					$.post("orgz/SysBranchAction!getPidSysBranch.action", {"reqData":row["pid"]}, function(data){
						if(data.status == "0"){
							var arrstr = "";
						    arrstr = data.data[0]["BRCH_ID"];
							$("#pid").combotree("setValues", arrstr);
						}
					}, "json");
					$.post("orgz/SysBranchAction!getBranchBanks.action", {"reqData":row["brchId"]}, function(data){
						if(data.status == "0"){
							var arr = [];
							for(var i in data.data){
								arr.unshift(data.data[i]["BANK_ID"]);
							}
							$("#bankIds").combobox("setValues", arr);
						}
					}, "json");
				},			
				buttons : [ {
					text : "编辑",
					iconCls : "icon-ok",
					handler : function() {
						$.modalDialog.openner= $grid;//因为添加成功之后，需要刷新这个treegrid，所以先预定义好
						jConfirm("您确定要修改网点信息吗？",function(r){
							var f = $.modalDialog.handler.find("#form");
							f.submit();
						});
					}
				}, {
					text : "取消",
					iconCls : "icon-cancel",
					handler : function() {
						$.modalDialog.handler.dialog("destroy");
						$.modalDialog.handler = undefined;
					}
				}
				]
			});
		}else{
			jAlert("请选择一行记录！","warning");
		}
	}
	function addRowsOpenDlg() {
		var row = $dg.treegrid("getSelected");
		$.modalDialog({
			title:"添加网点",
			iconCls:"icon-adds",
			fit:true,
			maximized:true,
			shadow:false,
			closable:false,
			maximizable:false,
			href:"jsp/organization/organizationAddDlg.jsp",
			onLoad:function(){
				if(row){
					var f = parent.$.modalDialog.handler.find("#form");
					f.form("load", {"pid":row.SysBranchId});
				}
			},
			buttons:[
				{
					text:"保存",
					iconCls:"icon-ok",
					handler:function() {
						$.modalDialog.openner = $grid;
						$.modalDialog.openner = $grid;
						jConfirm("您确定要新增输入的网点信息吗？",function(r){
							var f = $.modalDialog.handler.find("#form");
							f.submit();
						});
					}
				}, 
				{
					text:"取消",
					iconCls:"icon-cancel",
					handler:function() {
						$.modalDialog.handler.dialog("destroy");
						$.modalDialog.handler = undefined;
					}
				}
			]
		});
	}
	function accOpen(){
		var row = $dg.treegrid("getSelected");
		if (row) {
			$.ajax({
				type: "POST",
				url: "orgz/SysBranchAction!openBrchAcc.action?brchId="+row.brchId,
				cache: false,
				dataType : "json",
				success: function(data){
					jAlert(data.message,"info");
				}
	        }); 
		}else{
			jAlert("请选择一行记录！","warning");
		}
	}
	function query(){
		$dg.treegrid("expandTo", $("#brchName").combobox("getValue"));
		$dg.treegrid("select", $("#brchName").combobox("getValue"));
		$dg.treegrid("scrollTo", $("#brchName").combobox("getValue"));
	}
</script>
<n:initpage title="网点信息进行管理！<span style='color:red'>注意：</span>注销网点时，如果该网点下有子网点则无法直接进行注销，需要自下而向一级一级注销！">
  	<n:center>
	    <div id="tb" style="padding:2px;height:auto">
	        <table class="tablegrid">
		        <tr>
			        <td>
			        	<label for="brchName">网点名称：</label>
			        	<input id="brchName" class="textinput"/>
			        	<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="true" onclick="query();">查询</a>
						<shiro:hasPermission name="brchAdd">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add" plain="true" onclick="addRowsOpenDlg();">添加</a>
						</shiro:hasPermission>
						<shiro:hasPermission name="brchEdit">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="true" onclick="updRowsOpenDlg();">编辑</a>
						</shiro:hasPermission>
						<shiro:hasPermission name="brchDel">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove" plain="true" onclick="delRows();">注销</a>
						</shiro:hasPermission>
						<shiro:hasPermission name="brchAccOpen">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove" plain="true" onclick="accOpen();">开户</a>
						</shiro:hasPermission>
					</td>
				</tr>
			</table>	
		</div>
	    <table id="dg" title="网点管理"></table>
  	</n:center>
</n:initpage>