<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<!-- 柜面业务查询 -->
<script type="text/javascript"> 
	var $grid;
	var totalNum = 0;
	var totalAmt = 0.00;
	$(function() {
		createLocalDataSelect({
			id:"dealState",
			data:[
				{value:"",text:"请选择"},
				{value:"0",text:"有效"},
				{value:"1",text:"撤销"},
				{value:"2",text:"冲正"},
				{value:"9",text:"灰记录"}
			]
		});
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_LIST%>"
		});
		createSysCode({
			id:"certType",
			codeType:"CERT_TYPE"
		});
		createSysBranch({
			id:"branchId"},{
			id:"userId"
		});
		$grid = createDataGrid({
			id:"dg",
			url:"statistical/statisticalAnalysisAction!businessQuery.action",
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			pageSize:50,
			singleSelect:false,
			autoRowHeight:true,
			showFooter:true,
			pageList:[50,100,200,300,500,1000],
			frozenColumns:[[
				{field:"DEAL_NO1",title:"id",sortable:true,checkbox:"ture"},
				{field:"DEAL_NO",title:"流水号",sortable:true},
				{field:"DEAL_CODE_NAME",title:"业务名称",sortable:true},
				{field:"CUSTOMER_ID",title:"客户编号",sortable:true},
				{field:"CUSTOMER_NAME",title:"客户姓名",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"CERT_TYPE",title:"证件类型",sortable:true,width:parseInt($(this).width()*0.05)},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width()*0.12)}
			]],
			columns :[[
				{field:"CARD_TYPE",title:"卡类型",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width()*0.13)},
				{field:"ACCKIND",title:"账户类型",sortable:true},
				{field:"CARD_TR_COUNT",title:"交易序列号",sortable:true},
				{field:"PRV_BAL",title:"交易前金额",sortable:true, formatter:function(value, row){
					if(row.isFooter){
						return value;
					}
					return $.foramtMoney(Number(value).div100());
				}},
				{field:"AMT",title:"交易金额",sortable:true, formatter:function(value, row){
					return $.foramtMoney(Number(value).div100());
				}},
				{field:"BIZ_TIME",title:"办理时间",sortable:true,width:parseInt($(this).width()*0.12)},
				{field:"FULL_NAME",title:"办理网点",sortable:true},
				{field:"NAME",title:"柜员",sortable:true},
				{field:"CO_ORG_ID",title:"合作机构编号",sortable:true},
				{field:"CO_ORG_NAME",title:"合作名称",sortable:true},
				{field:"TERM_ID",title:"终端编号",sortable:true},
				{field:"END_DEAL_NO",title:"终端流水",sortable:true},
				{field:"GRT_USER_ID",title:"业务授权人编号",sortable:true},
				{field:"GRT_USER_NAME",title:"业务授权人",sortable:true},
				{field:"CLR_DATE",title:"清分日期",sortable:true},
				{field:"OLD_CARD_NO",title:"老卡卡号",sortable:true},
				{field:"OLD_DEAL_NO",title:"原始流水",sortable:true},
				{field:"DEAL_STATE",title:"状态",sortable:true},
				{field:"AGT_CERT_TYPE",title:"代理人证件类型",sortable:true},
				{field:"AGT_CERT_NO",title:"代理人证件号码",sortable:true},
				{field:"AGT_NAME",title:"代理人姓名",sortable:true},
				{field:"AGT_TEL_NO",title:"代理人联系方式",sortable:true},
				{field:"NOTE",title:"备注",sortable:true}
		    ]],
		    onLoadSuccess:function(data){
		    	if(data.status == 1){
		    		jAlert(data.errMsg);
		    	}
		    	initCal();
			    updateFooter();
		    },
		    onSelect:function(index, row){
		    	calRow(true, row);
		    	updateFooter();
		    },
			onUnselect:function(index, row){
		    	calRow(false, row);
		    	updateFooter();
		    },
		    onSelectAll:function(row){
		    	initCal();
		    	for(var i in row){
			    	calRow(true, row[i]);
		    	}
			    updateFooter();
		    },
		    onUnselectAll:function(){
		    	initCal();
			    updateFooter();
		    }
		});
		$.autoComplete({
			id:"coOrgId",
			value:"co_Org_Name",
			text:"co_Org_Id",
			table:"base_co_org",
			where:"co_state = '0' ",
			keyColumn:"co_Org_Id",
			minLength:1
		},"coOrgName");
		$.createDealCode("dealCode");
	});	
	function initCal(){
		totalNum = 0;
		totalAmt = 0.00;
	}
	function calRow(is,data){
		if(is){
			totalNum = parseFloat(totalNum) + parseFloat(1);
       	  	totalAmt += isNaN(data.AMT)||!data.AMT?0:Number(data.AMT);
		}else{
			totalNum = parseFloat(totalNum) - parseFloat(1);
       	  	totalAmt -= isNaN(data.AMT)||!data.AMT?0:Number(data.AMT);
		}
	}
	function updateFooter(){
		$grid.datagrid("reloadFooter",[{
			isFooter:true,
			DEAL_CODE_NAME:"本页信息统计：",
			CUSTOMER_ID:"笔数",
			CUSTOMER_NAME:parseFloat(totalNum),
			PRV_BAL :"金额",
        	AMT:parseFloat(totalAmt).toFixed(2)}
        ]);
	}
	function query(){
		totalNum = 0;
		totalAmt = 0.00;
		var params = getformdata("businessFrom");
		params["queryType"] = "0";
		if(!$("#beginTime").val()&&!$("#beginTime").val()&&params["isNotBlankNum"] < 1){
			$.messager.alert("系统消息","查询参数不能全部为空！请至少输入或选择一个查询参数","warning");
			return;
		}
		if($("#beginTime").val().replace(/\s/g,"") != ""){
			params["beginTime"] = $("#beginTime").val().replace(/\D/g,"");
		}
		if($("#endTime").val().replace(/\s/g,"") != ""){
			params["endTime"] = $("#endTime").val().replace(/\D/g,"");
		}
		$grid.datagrid("load",params);
	}
	function readCard(){
		$.messager.progress({text:"正在获取卡片信息，请稍后...."});
		cardmsg = getcardinfo();
		if(dealNull(cardmsg["card_No"]).length == 0){
			$.messager.progress("close");
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardmsg["errMsg"],"error");
			return;
		}
		$.messager.progress("close");
		$("#cardNo").val(cardmsg["card_No"]);
	}
	function readIdCard(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var certinfo = getcertinfo();
		if(dealNull(certinfo["cert_No"]).length < 15){			
			$.messager.progress("close");
			return;
		}
		$.messager.progress("close");
		$("#certNo").val(certinfo["cert_No"]);
	}
	
	function exportDetail(){
		var selections = $grid.datagrid("getSelections");
		var dealNos = "";
		if(selections && selections.length > 0){
			for(var i in selections){
				dealNos += selections[i].DEAL_NO + ",";
			}
		}
		var url = 'statistical/statisticalAnalysisAction!exportBusinessInfo.action?queryType=0&rows=20000&dealNos=' + dealNos.substring(0, dealNos.length - 1) + '&' + $("#businessFrom").serialize();
		if($("#beginTime").val().replace(/\s/g,"") != ""){
			url += "&beginTime=" + $("#beginTime").val().replace(/\D/g,"");
		}
		if($("#endTime").val().replace(/\s/g,"") != ""){
			url += "&endTime=" + $("#endTime").val().replace(/\D/g,"");
		}
		$('#downloadcsv').attr('src',url);
	}
</script>
<n:initpage title="系统业务日志进行查询操作！">
	<n:center>
		<div id="tb" style="padding:2px 0">
			<form id="businessFrom">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">卡号：</td>
						<td class="tableright"><input  id="cardNo" type="text"  class="textinput" name="rec.cardNo"/></td>
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input  id="cardType" type="text"  class="textinput" name="rec.cardType"/></td>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input  id="certNo" type="text"  class="textinput" name="rec.certNo"/></td>
						<td class="tableleft">证件类型：</td>
						<td class="tableright"><input  id="certType" type="text"  class="textinput" name="rec.certType"/></td>
					</tr>
					<tr>
						<td class="tableleft">老卡卡号：</td>
						<td class="tableright"><input  id="oldCardNo" type="text"  class="textinput" name="rec.oldCardNo"/></td>
						<td class="tableleft">原始流水：</td>
						<td class="tableright"><input  id="oldDealNo" type="text"  class="textinput" name="rec.oldDealNo"/></td>
						<td class="tableleft">起始日期：</td>
						<td class="tableright"><input  id="beginTime" type="text" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss',qsEnabled:false,maxDate:'%y-%M-%d 0:0:0'})"/></td>
						<td class="tableleft">结束日期：</td>
						<td class="tableright"><input id="endTime" type="text" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					</tr>
					<tr>
						<td class="tableleft">办理网点：</td>
						<td class="tableright"><input id="branchId" type="text" class="textinput " name="branchId"/></td>
						<td class="tableleft">办理柜员：</td>
						<td class="tableright"><input id="userId" type="text" class="textinput " name="userId"/></td>
						<td class="tableleft">合作机构编号：</td>
						<td class="tableright"><input  id="coOrgId" type="text"  class="textinput" name="rec.coOrgId"/></td>
						<td class="tableleft">合作机构名称：</td>
						<td class="tableright"><input  id="coOrgName" type="text"  class="textinput" name="coOrgName"/></td>
					</tr>
					<tr>
						<td class="tableleft">交易代码：</td>
						<td class="tableright"><input  id="dealCode" type="text" class="textinput" name="rec.dealCode"/></td>
						<td class="tableleft">流水号：</td>
						<td class="tableright"><input  id="dealNo" type="text" class="textinput" name="rec.dealNo"/></td>
						<td class="tableleft">记录状态：</td>
						<td class="tableright"><input  id="dealState" type="text" class="textinput" name="rec.dealState"/></td>
						<td align="center" colspan="2">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="readCard()">读卡</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" onclick="exportDetail()">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="业务日志信息"></table>
  		<iframe id="downloadcsv" style="display:none"></iframe>
    </n:center>
</n:initpage>