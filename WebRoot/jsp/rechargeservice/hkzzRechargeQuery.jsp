<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript"> 
	var $grid;
	var totalNum = 0;
	var totalAmt = 0.00;
	$(function() {
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_LIST%>"
		});
		$("#synGroupIdTip").tooltip({
			position:"left",    
			content:"<span style='color:#B94A48'>是否级联下级网点</span>" 
		});
		$("#cascadeBrch").switchbutton({
			width:"50px",
			value:"0",
            checked:false,
            onText:"是",
            offText:"否"
		});
		createSysBranch("brchId");
		$grid = createDataGrid({
			id:"dg",
			url:"statistical/statisticalAnalysisAction!hkzzRechargeQuery.action",
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			pageList:[100, 500, 1000, 2000, 5000],
			singleSelect:false,
			autoRowHeight:true,
			showFooter:true,
			frozenColumns:[[
				{field:"DEAL_NO1",title:"id",sortable:true,checkbox:"ture"},
				{field:"DEAL_NO",title:"流水号",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"DEAL_BATCH_NO",title:"批次号",sortable:true,width:parseInt($(this).width()*0.08),hidden:true},
				{field:"DEAL_CODE",title:"业务名称",sortable:true,width:parseInt($(this).width()*0.09)},
				{field:"ACPT_ID",title:"网点编号",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"FULL_NAME",title:"网点名称",sortable:true,width:parseInt($(this).width()*0.11)}
			]],
			columns:[[
				{field:"CUSTOMER_ID",title:"客户编号",hidden:true,sortable:true},
				{field:"ACC_NAME",title:"客户姓名",sortable:true},
				{field:"GENDER",title:"性别",hidden:true,sortable:true},
				{field:"CERT_TYPE",title:"证件类型",hidden:true,sortable:true},
				{field:"CERT_NO",title:"证件号码",sortable:true},
				{field:"CARD_TYPE",title:"卡类型",sortable:true},
				{field:"CARD_NO",title:"卡号",sortable:true},
				{field:"ACC_NO",title:"账户号",hidden:true,sortable:true},
				{field:"ACC_KIND",title:"账户类型",sortable:true},
				{field:"CARD_BAL",title:"交易前金额",sortable:true,formatter:function(value,row,index){
					if(row.isFooter){
						return value;
					}
					return $.foramtMoney(Number(value).div100());
				}},
				{field:"AMT",title:"交易金额",sortable:true,formatter:function(value,row,index){
					return $.foramtMoney(Number(value).div100());
				}},
				{field:"DEAL_DATE",title:"交易时间",sortable:true},
				{field:"END_DEAL_NO",title:"终端交易流水号",sortable:true, hidden:true},
				{field:"CARD_COUNTER",title:"卡交易序列号",sortable:true},
				{field:"USER_ID",title:"柜员编号",sortable:true},
				{field:"NAME",title:"柜员",sortable:true},
				{field:"CLR_DATE",title:"清分日期",sortable:true},
				{field:"DEAL_STATE",title:"状态",sortable:true},
				{field:"NOTE",title:"备注",sortable:true}
			]],
		  	onCheck:function(index,data){
		  		calRow(true,data);
            	updateFooter();
            },
            onUncheck:function(index,data){
            	calRow(false,data);
            	updateFooter();
            },
            onCheckAll:function(rows){
            	initCal();
            	var i = 0;
            	var maxL = rows.length;
            	for(;i < maxL;i++){
            		calRow(true,rows[i]);
            	}
            	updateFooter();
            },
            onUncheckAll:function(rows){
            	initCal();
            	updateFooter();
            },
            onLoadSuccess:function(data){
            	if(data.status != 0){
            		jAlert(data.errMsg,"warning");
            	}
            	initCal();
            	updateFooter();
            }
		});
	});
	function initCal(){
		totalNum = 0;
		totalAmt = 0.00;
	}
	function calRow(is,data){
		if(is){
			totalNum = parseFloat(totalNum) + parseFloat(1);
       	  	totalAmt = parseFloat(totalAmt) + parseFloat(data.AMT);
		}else{
			totalNum = parseFloat(totalNum) - parseFloat(1);
       	  	totalAmt = parseFloat(totalAmt) - parseFloat(data.AMT);
		}
	}
	function updateFooter(){
		$grid.datagrid("reloadFooter",[{
			isFooter:true,
        	DEAL_CODE:"本页信息统计：",
        	ACPT_ID:"笔数",
        	FULL_NAME:parseFloat(totalNum),
        	CARD_BAL :"金额",
        	AMT:parseFloat(totalAmt).toFixed(2)}
        ]);
	}
	function query(){
		initCal();
		var params = getformdata("searchConts");
		params["queryType"] = "0";
		params["cascadeBrch"] = $("#cascadeBrch").prop("checked")
		$grid.datagrid("load",params);
	}
	function readCard(){
		$.messager.progress({text : "正在验证卡信息,请稍后..."});
		cardinfo = getcardinfo();
		$.messager.progress("close");
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！","error");
			return;
		}
		$("#cardNo").val(cardinfo["card_No"]);
		query();
	}
	
	function exportDetail(){
		var selections = $grid.datagrid("getSelections");
		var dealNos = "";
		if(selections && selections.length > 0){
			for(var i in selections){
				dealNos += selections[i].DEAL_NO + ",";
			}
		}
		$('#downloadcsv').attr('src','statistical/statisticalAnalysisAction!exportHkzzRechargeInfo.action?queryType=0&rows=20000&cascadeBrch=' + $("#cascadeBrch").prop("checked") + '&dealNos=' + dealNos.substring(0, dealNos.length - 1) + '&' + $("#searchConts").serialize());
	}
</script>
<n:initpage title="换卡转钱包充值信息进行查询！">
	<n:center>
		<div id="tb">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">办理网点：</td>
						<td class="tableright">
							<input id="brchId" type="text" class="textinput" name="branchId"/>
							<span id="synGroupIdTip">
								<input id="cascadeBrch" name="cascadeBrch" type="checkbox">
							</span>
						</td>
						<td class="tableleft">起始日期：</td>
						<td class="tableright"><input  id="beginTime" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">结束日期：</td>
						<td class="tableright"><input id="endTime" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					</tr>
					<tr>
						<td class="tableleft">流水号：</td>
						<td class="tableright"><input id="dealNo" type="text"  class="textinput easyui-validatebox" name="dealNo"/></td>
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="cardType" type="text" class="textinput" name="cardType"/></td>
						<td class="tableleft">卡号：</td>
						<td class="tableright">
							<input id="cardNo" type="text" class="textinput" name="cardNo"/>
							&nbsp;&nbsp;<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
							&nbsp;&nbsp;<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							&nbsp;&nbsp;<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" onclick="exportDetail()">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="换卡转钱包充值信息"></table>
  		<iframe id="downloadcsv" style="display:none"></iframe>
  	</n:center>
</n:initpage>