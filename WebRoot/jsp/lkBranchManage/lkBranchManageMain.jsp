<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var isCorpOrComm = "0";
	var $lkBranchDataGrid;
	$(function(){
		$("#import_dialog2").dialog({
			title : "导入数据",
			width : 400,
		    height : 185,
		    modal: true,
		    closed : true,
			onClose : function(){
			},
			onBeforeOpen : function(){
				$("#file")[0].value = "";
			}
		});

		$lkBranchDataGrid = createDataGrid({
			id:"lkBranchDataGrid",
			toolbar:"#tb",
			url:"lkBranch/lkBranchAction!findAllLkBranch.action",
			pageSize:20,
			onBeforeLoad:function(param){
				if(typeof(param["queryType"]) == "undefined" || param["queryType"] != 0){
					return false;
				}
			},
			columns:[[
				{field:"V_V",checkbox:true},
				{field:"CORP_OR_COMM_ID",title:"单位编号/社区（村）编号",align:"center",sortable:true},
				{field:"CORP_OR_COMM_NAME",title:"单位名称/社区（村）名称",align:"center",sortable:true},
				{field:"LK_BRANCH_ID",title:"金融市民卡领卡网点编号",align:"center",sortable:true},
				{field:"LK_BRANCH_NAME",title:"金融市民卡领卡网点名称",align:"center",sortable:true},
				{field:"LK_BRCH_ID2",title:"全功能卡领卡网点编号",align:"center",sortable:true},
				{field:"LK_BRANCH_NAME2",title:"全功能卡领卡网点名称",align:"center",sortable:true},
				{field:"IS_BATCH_HF",title:"是否完成换发",align:"center",sortable:true, formatter:function(v){
					if(v == "0"){
						return "是";
					}else{
						return "否";
					}
				}},
				{field:"BIZ_TIME",title:"修改时间",sortable:true},
				{field:"BRCH_NAME",title:"修改网点",sortable:true},
				{field:"USER_NAME",title:"修改柜员",sortable:true}
			]]
		});
		createLocalDataSelect({
			id:"isCorpOrComm",
			data:[{value:"0",text:"单位",selected:true},{value:"1",text:"社区（村）"}],
			onSelect:function(option){
				if(option.value == "0"){
					$("#corpCondition").css("display","table-row");
					$("#commCondition").css("display","none");
				}else if(option.value == "1"){
					$("#corpCondition").css("display","none");
					$("#commCondition").css("display","table-row");
				}
			}
		});
		createLocalDataSelect({
			id:"isSettings",
			data:[{value:"",text:"请选择"},{value:"0",text:"是"},{value:"1",text:"否"}]
		});
		createRegionSelect({id:"regionId"},{id:"townId"},{id:"commId"});
		createSysOrg({id:"orgId",isJudgePermission:false},{id:"branchId"});
	});
	function autoCom(){
        if($("#corpCustomerId").val() == ""){
            $("#corpName").val("");
        }
        $("#corpCustomerId").autocomplete({
            source: function(request,response){
                $.post('corpManager/corpManagerAction!initAutoComplete.action',{"customerId":$("#corpCustomerId").val(),jugeCorp:true},function(data){
                    response($.map(data.rows,function(item){return {label:item.LABEL,value:item.TEXT}}));
                },'json');
            },
            select: function(event,ui){
                $('#corpCustomerId').val(ui.item.label);
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
            $("#corpCustomerId").val("");
        }
        $("#corpName").autocomplete({
            source:function(request,response){
                $.post('corpManager/corpManagerAction!initAutoComplete.action',{"corpName":$("#corpName").val(),jugeCorp:true},function(data){
                    response($.map(data.rows,function(item){return {label:item.TEXT,value:item.LABEL}}));
                },'json');
            },
            select: function(event,ui){
                $('#corpCustomerId').val(ui.item.value);
                $('#corpName').val(ui.item.label);
                return false;
            },
            focus: function(event,ui){
                return false;
            }
        }); 
    }
	function lkBranchQuery(){
		isCorpOrComm = $("#isCorpOrComm").combobox("getValue");
		$lkBranchDataGrid.datagrid("load",{
			"queryType":"0",
			"isCorpOrComm":isCorpOrComm,
			"branchId":$("#branchId").combobox("getValue"),
			"isSettings":$("#isSettings").combobox("getValue"),
			"corpCustomerId":$("#corpCustomerId").val(),
			"corpName":$("#corpName").val(),
			"regionId":$("#regionId").combobox("getValue"),
			"townId":$("#townId").combobox("getValue"),
			"commId":$("#commId").combobox("getValue")
		});
	}
	function getLkBranch(){
		var row = $lkBranchDataGrid.datagrid("getSelected");
		if(row){
			if(isCorpOrComm != "0" && isCorpOrComm != "1"){
				$.messager.alert("系统消息","操作类型传入错误！","error");
				return;
			}
			$.modalDialog({
				title:"单位/社区（村）领卡网点设置",
				iconCls:"icon-edit",
				width:700,
				height:200,
				shadow:false,
				closable:false,
				maximizable:false,
				href:"lkBranch/lkBranchAction!getLkBranch.action?isCorpOrComm=" + isCorpOrComm + "&corpOrCommId=" + row.CORP_OR_COMM_ID,
				buttons:[{
					text:"设置",
					iconCls:"icon-ok",
					handler:function(){
						settingLkBranch();
					}
				},{
					text:"取消",
					iconCls:"icon-cancel",
					handler:function() {
						$.modalDialog.handler.dialog("destroy");
						$.modalDialog.handler = undefined;
					}
				}]
			});
		}else{
			$.messager.alert("系统消息","请选择一条信息进行设置！","error");
		}
	}
	function openDialog2(){
		$("#import_dialog2").dialog("open");
	}
	function importCorp() {
		var val = $("#file").val();
		if(!val){
			jAlert("请选择导入文件", "warning");
			return;
		}
		$.messager.progress({text:"数据处理中，请稍候..."});
		$.ajaxFileUpload({  
            url:"lkBranch/lkBranchAction!importCorpSetting.action",
            fileElementId:['file'],
            dataType:"json",
            success: function(data, status){
            	$.messager.progress("close");
            	
            	var hasFailItem = false;
            	var msg = "";
            	if(data.status == '0'){
        			if(data.msgList && data.msgList.length > 0){
        				hasFailItem = true;
    					var array = data.msgList;
    					for(var i in array){
    						msg += "单位编号:<span style='color:red'>" + array[i].corpId + "</span>, 领卡网点编号:<span style='color:red'>" + array[i].lkBrchId + "</span>, 失败原因: <span style='color:red'>" + array[i].failMsg + "</span><br>";
    					}
    				}
        			if(hasFailItem){
        				$.messager.confirm("消息提示", "操作成功，共 " + data.count + " 条数据， 成功 " + data.succNum + " 条， 有失败的数据, 点击确定查看", function(r){
        					if(r){
        						$("#cardbindwin").html(msg);
        						$("#cardbindwin").window({
        							title:"失败数据",
        							width:600,    
        						    height:400,    
        						    modal:true,
        						    collapsible:false,
        						    minimizable:false,
        						    maximizable:false,
        						    onClose:function(){
        						    	$("#import_dialog2").dialog("close");
        	        	            	$lkBranchDataGrid.datagrid("reload");
        						    }
        						});
        						$("#cardbindwin").show();
        					}
        				});
        			} else {
        				$.messager.alert("消息提示","操作成功，共 " + data.count + " 条数据， 成功 " + data.succNum + "", "info", function(){
        					$("#import_dialog2").dialog("close");
        	            	$lkBranchDataGrid.datagrid("reload");
        				});
        			}
            	}else{
            		$.messager.alert('消息提示',data.errMsg,'error', function(){
            			$("#import_dialog2").dialog("close");
    	            	$lkBranchDataGrid.datagrid("reload");
            		});
            	}
            }
        });
	}
	function downloadTemplate2(){
		$("#import_dialog2").children("iframe").attr("src", "merchantRegister/merchantRegisterAction!downloadTemplate.action?template=importCorpSetting");
	}
</script>
<n:initpage title="单位/社区（村）领卡网点设置">
	<n:center>
		<div id="tb" style="padding:2px 0">
			<form id="lkBranchForm">
				<table style="width:100%" class="tablegrid">
					<tr>
						<td class="tableleft" style="width:8%">单位/社区（村）选择：</td>
						<td class="tableright" style="width:17%"><input type="text" id="isCorpOrComm" class="textinput"/></td>
						<td class="tableleft" style="width:8%">机构名称：</td>
						<td class="tableright" style="width:17%"><input type="text" id="orgId" class="textinput" name="orgId"/></td>
						<td class="tableleft" style="width:8%">领卡网点：</td>
						<td class="tableright" style="width:17%"><input type="text" id="branchId" class="textinput"/></td>
						<td class="tableleft" style="width:8%">是否已设置：</td>
						<td class="tableright" style="width:17%"><input type="text" id="isSettings" class="textinput"/></td>
					</tr>
					<tr id="corpCondition" style="display:table-row;">
						<td class="tableleft" style="width:8%">单位编号：</td>
						<td class="tableright" style="width:17%"><input type="text" id="corpCustomerId" class="textinput" onchange="autoCom();" onkeyup="autoCom();" onkeydown="autoCom();"/></td>
						<td class="tableleft" style="width:8%">单位名称：</td>
						<td class="tableright" style="width:17%"><input type="text" id="corpName" class="textinput" onchange="autoComByName();" onkeyup="autoComByName();" onkeydown="autoComByName();"/></td>
						<td class="tableright" colspan="4" style="width:50%">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="lkBranchQuery();">查询</a>
							<shiro:hasPermission name="lkBranchSet">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="getLkBranch();">设置</a>
								<a id="importCorp" href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-import'"  onclick="openDialog2()">导入设置</a>
							</shiro:hasPermission>
						</td>
					</tr>
					<tr id="commCondition" style="display:none;">
						<td class="tableleft" style="width:8%">所属区域：</td>
						<td class="tableright" style="width:17%"><input type="text" id="regionId" class="textinput"/></td>
						<td class="tableleft" style="width:8%">乡镇(街道)：</td>
						<td class="tableright" style="width:17%"><input type="text" id="townId" class="textinput"/></td>
						<td class="tableleft" style="width:8%">社区(村)：</td>
						<td class="tableright" style="width:17%"><input type="text" id="commId" class="textinput"/></td>
						<td class="tableright" colspan="2" style="width:25%">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="lkBranchQuery();">查询</a>
							<shiro:hasPermission name="lkBranchSet">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="getLkBranch();">设置</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="lkBranchDataGrid" title="单位/社区（村）领卡网点设置" style="display:table;"></table>
		<div id="import_dialog2" style="padding: 5% 10% 0 10%;" class="datagrid-toolbar">
	  		<table width="100%">
				<tr>
					<td>
						<input id="file" name="file" type="file" style="border: 1px #ccc solid;" accept="application/vnd.ms-excel">
						<button onclick="importCorp()">导入</button>
					</td>
				</tr>
			</table>
			<br>
			<a href="javascript:void(0)" onclick="downloadTemplate2()">点击此处</a>下载导入模版
			<iframe style="display: none;"></iframe>
  		</div>
  		<div id="cardbindwin"></div>
	</n:center>
</n:initpage>