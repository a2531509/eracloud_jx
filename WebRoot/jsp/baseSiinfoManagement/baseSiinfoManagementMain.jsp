<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $baseSiinfo;
	$(function() {
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no",
			//minLength:"1"
		},"name");
		$.autoComplete({
			id:"name",
			text:"name",
			value:"cert_no",
			table:"base_personal",
			keyColumn:"name",
			minLength:"1"
		},"certNo");
		$.autoComplete({
			id:"corpCustomerId",
			text:"customer_id",
			value:"corp_name",
			table:"base_corp",
			where:"corp_state = '0'",
			keyColumn:"customer_id",
			minLength:1
		},"corpName");
		$.autoComplete({
			id:"corpName",
			text:"corp_name",
			value:"customer_id",
			table:"base_corp",
			where:"corp_state = '0'",
			keyColumn:"corp_name",
			minLength:1
		},"corpCustomerId");
		createCustomSelect({
			id:"medWholeNo",
			value:"city_id",
			text:"region_name",
			table:"base_region",
			where:"region_state = '0'",
			orderby:"city_id asc",
			onSelect:function(option){
				if(option && option.VALUE != ""){
					$("#medWholeNo").val(option.TEXT);
				}else{
					$("#medWholeNo").val("");
				}
			},
			onLoadSuccess:function(){
				var defaultValue = $("#medWholeNo").combobox("getValue");
				var defaultText = "";
				if(defaultValue == "erp2_erp2"){
					defaultValue = "";
				}else{
					defaultText = $("#medWholeNo").combobox("getText");
				}
				var alldatas =  $("#medWholeNo").combobox("getData");
				if(dealNull(defaultValue) == ""){
					if(alldatas && alldatas.length > 0){
						defaultValue = alldatas[0].VALUE;
						defaultText = alldatas[0].TEXT;
					}
				}
				if(defaultValue != ""){
					$("#medWholeNo").val(defaultText);
				}else{
					$("#medWholeNo").val("");
				}
				$("#medWholeNo").combobox('setValue',defaultValue);
			}
		});
		createLocalDataSelect({
			id:"gender",
		    data:[{value:'',text:"请选择"},{value:'0',text:"未知"},{value:'1',text:"男"},{value:'2',text:"女"},{value:'9',text:"未说明"}]
		});
		createLocalDataSelect({
			id:"medState",
			data:[{value:'',text:"请选择"},{value:'0',text:"是"},{value:'1',text:"否"}]
		});
		$baseSiinfo = createDataGrid({
			id : "baseSiinfo",
			toolbar : "#tb",
			url : "baseSiinfo/baseSiinfoAction!findAllBaseSiinfo.action",
			pageSize : 20,
			onBeforeLoad:function(param){
				if(typeof(param["queryType"]) == "undefined" || param["queryType"] != 0){
					return false;
				}
			},
			frozenColumns:[[
				{field:'V_V',checkbox:true},
				{field:"PERSONAL_ID",title:"社保编号",align:'center',sortable:true,width:parseInt($(this).width()*0.07)},
				{field:"MED_WHOLE_NO",title:"统筹区编码",align:'center',sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"REGION_NAME",title:"统筹区名称",align:'center',sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"COMPANY_ID",title:"社保单位编号",align:'center',sortable:true},
				{field:"CORP_CUSTOMER_ID",title:"单位编号",align:'center',sortable:true},
				{field:"CORP_NAME",title:"单位名称",align:'center',sortable:true},
				{field:"CUSTOMER_ID",title:"客户编号",align:'center',sortable:true},
				{field:"NAME",title:"客户姓名",align:'center',sortable:true}
			]],
			columns:[[
				{field:"GENDER_NAME",title:"性别",align:'center',sortable:true,width:parseInt($(this).width()*0.03)},
				{field:"CERT_TYPE_NAME",title:"证件类型",align:'center',sortable:true,width:parseInt($(this).width()*0.05)},
				{field:"CERT_NO",title:"证件号码",align:'center',sortable:true},
				{field:"BIRTHDAY_F",title:"出生日期",align:'center',sortable:true},
				{field:"ENDOW_STATE",title:"养老参保状态是否正常",align:'center',sortable:true,
					formatter:function(value,row,index){
						return isNormal(value);
					}
				},
				{field:"MED_STATE",title:"医保参保状态是否正常",align:'center',sortable:true,
					formatter:function(value,row,index){
						return isNormal(value);
					}
				},
				{field:"INJURY_STATE",title:"工伤参保状态是否正常",align:'center',sortable:true,
					formatter:function(value,row,index){
						return isNormal(value);
					}
				},
				{field:"BEAR_STATE",title:"生育参保状态是否正常",align:'center',sortable:true,
					formatter:function(value,row,index){
						return isNormal(value);
					}
				},
				{field:"UNEMP_STATE",title:"失业参保状态是否正常",align:'center',sortable:true,
					formatter:function(value,row,index){
						return isNormal(value);
					}
				},
				{field:"MED_CERT_NO",title:"医疗证号",align:'center',sortable:true},
				{field:"RESERVE_1",title:"RESERVE_1",sortable:true},
				{field:"RESERVE_2",title:"RESERVE_2",sortable:true},
				{field:"RESERVE_3",title:"RESERVE_3",sortable:true},
				{field:"RESERVE_4",title:"RESERVE_4",sortable:true},
				{field:"RESERVE_5",title:"RESERVE_5",sortable:true},
				{field:"RESERVE_6",title:"RESERVE_6",sortable:true},
				{field:"RESERVE_7",title:"RESERVE_7",sortable:true},
				{field:"RESERVE_8",title:"RESERVE_8",sortable:true},
				{field:"RESERVE_9",title:"RESERVE_9",sortable:true},
				{field:"RESERVE_10",title:"RESERVE_10",sortable:true},
				{field:"RESERVE_11",title:"RESERVE_11",sortable:true},
				{field:"RESERVE_12",title:"RESERVE_12",sortable:true},
				{field:"RESERVE_13",title:"RESERVE_13",sortable:true},
				{field:"RESERVE_14",title:"RESERVE_14",sortable:true},
				{field:"RESERVE_15",title:"RESERVE_15",sortable:true},
				{field:"RESERVE_16",title:"RESERVE_16",sortable:true},
				{field:"RESERVE_17",title:"RESERVE_17",sortable:true},
				{field:"RESERVE_18",title:"RESERVE_18",sortable:true},
				{field:"RESERVE_19",title:"RESERVE_19",sortable:true},
				{field:"RESERVE_20",title:"备注",sortable:true},
				{field:"BIZ_TIME",title:"修改时间",sortable:true},
				{field:"BRCH_NAME",title:"修改网点",sortable:true},
				{field:"USER_NAME",title:"修改柜员",sortable:true}
	        ]]
		});
	});

	function query() {
	    	if($("#certNo").val() == "" && $("#corpCustomerId").val() == "" && $("#name").val() == "" && $("#corpName").val() == ""
					&& $("#medWholeNo").combobox("getValue") == "" && $("#personalId").val() == ""){
				$.messager.alert("系统消息","请输入查询条件！<div style=\"color:red\">提示：证件号码，姓名或单位编号、单位名称或社保编号至少输一项</div>","warning");
				return;
			}
	
		$baseSiinfo.datagrid("load",{
			"queryType" : "0",
			"baseSiinfo.id.personalId" : $("#personalId").val(),
			"baseCorp.customerId" : $("#corpCustomerId").val(),
			"baseCorp.corpName" : $("#corpName").val(),
			"baseSiinfo.customerId" : $("#customerId").val(),
			"baseSiinfo.name" : $("#name").val(),
			"baseSiinfo.certNo" : $("#certNo").val(),
			"baseSiinfo.birthday" : $("#birthday").val(),
			"baseSiinfo.gender" : $("#gender").combobox("getValue"),
			"baseSiinfo.medState" : $("#medState").combobox("getValue"),
			"baseSiinfo.id.medWholeNo" : $("#medWholeNo").combobox("getValue")
		});
	}
	
	function isNormal(value) {
		if(value == 0) {
			return "是";
		} else {
			return "否";
		}
	}	
	//编辑信息
	function addOrEditBaseSiinfo(type) {
		var row = $baseSiinfo.datagrid('getSelected');
		if(type == '0' || (row && type == '1')){
			var titlestring = "",titleicon = "",personalId = "";
			if(type == '1'){
				titlestring = "医保参保状态修改";
				titleicon = "icon-edit";
				customerId = row.CUSTOMER_ID;
			}else{
				$.messager.alert("系统消息","操作类型传入错误！","error");
				return;
			}
			$.modalDialog({
				title: "医保参保状态修改",
				iconCls:"icon-edit",
				width:650,
				height:200,
				shadow:false,
				closable:true,
				maximizable:false,
				href:"baseSiinfo/baseSiinfoAction!addOrEditBaseSiinfo.action?queryType=" + type + "&baseSiinfo.customerId=" + customerId,
				buttons:[{
						text:'保存',
						iconCls:'icon-ok',
						handler:function(){
							saveOrUpdateBaseSiinfo();
						}
					},{
						text:'取消',
						iconCls:'icon-cancel',
						handler:function() {
							$.modalDialog.handler.dialog('destroy');
						    $.modalDialog.handler = undefined;
						}
				}]
			});
		}else{
			$.messager.alert("系统消息","请选择一条记录信息进行编辑！","error");
		}
	}
	function readIdCard(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var o = getcertinfo();
		if(dealNull(o["name"]).length == 0){
			$.messager.progress("close");
			return;
		}
		$.messager.progress("close");
		$("#certNo").val(o["cert_No"]);
		query();
	}
</script>
<n:initpage title="参保信息进行管理，<span style='color:red'>注意：</span>修改参保信息时只允许修改医保参保状态！">
	<n:center>
		<div id="tb" style="padding:2px 0">
			<form id="baseSiinfoDetails">
				<table style="width:100%" class="tablegrid">
					<tr>
						<td class="tableleft" style="width:8%">证件号码：</td>
						<td class="tableright" style="width:17%"><input type="text" id="certNo" class="textinput" maxlength="18"/></td>
						<td class="tableleft" style="width:8%">客户姓名：</td>
						<td class="tableright" style="width:17%"><input type="text" id="name" class="textinput" maxlength="10"/></td>
						<td class="tableleft" style="width:8%">出生日期：</td>
						<td class="tableright" style="width:17%"><input type="text" id="birthday" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/></td>
						<td class="tableleft" style="width:8%">性别：</td>
						<td class="tableright" style="width:17%"><input type="text" id="gender" class="textinput"/></td>
					</tr>
					<tr>
						<td class="tableleft" style="width:8%">社保编号：</td>
						<td class="tableright" style="width:17%"><input type="text" id="personalId"  class="textinput"/></td>
						<td class="tableleft" style="width:8%">客户编号：</td>
						<td class="tableright" style="width:17%"><input type="text" id="customerId" class="textinput"/></td>
						<td class="tableleft" style="width:8%">单位编号：</td>
						<td class="tableright" style="width:17%"><input type="text" id="corpCustomerId" class="textinput"/></td>
						<td class="tableleft" style="width:8%">单位名称：</td>
						<td class="tableright" style="width:17%"><input type="text" id="corpName" class="textinput"/></td>
					</tr>
					<tr>
						<td class="tableleft" style="width:8%">医保状态是否正常：</td>
						<td class="tableright" style="width:17%"><input type="text" id="medState" class="textinput"/></td>
						<td class="tableleft" style="width:8%">参保统筹区：</td>
						<td class="tableright" style="width:17%"><input type="text" id="medWholeNo" class="textinput"/></td>
						<td class="tableright" style="width:50%" colspan="4">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<shiro:hasPermission name="baseSiinfoEdit">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-edit'" href="javascript:void(0);" class="easyui-linkbutton" onclick="addOrEditBaseSiinfo(1)">编辑</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="baseSiinfo" title="客户参保信息查询"></table>
	</n:center>
</n:initpage>